{
  description = "Oligarchy NixOS Lite - Ultra-minimal NixOS for legacy hardware, VMs, and Cloud";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # Helper to reduce repetition
      mkSystem = system: extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration-base.nix
        ] ++ extraModules;
      };

      profiles = {
        # x86_64 Standard
        minimal-x86_64 = mkSystem "x86_64-linux" [ ];

        # 512MB RAM / 1 Core Optimized ISO
        iso-minimal = mkSystem "x86_64-linux" [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ({ pkgs, lib, ... }: {
            zramSwap.enable = true;
            zramSwap.algorithm = "zstd";
            zramSwap.memoryPercent = 100;
            isoImage.squashfsCompression = "zstd";

            # FIX 1: Resolve autologin conflict
            services.getty.autologinUser = lib.mkForce "nixos";

            # FIX 2: Remove ZFS to save RAM and fix kernel errors
            boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

            # Strip heavy services
            documentation.enable = lib.mkForce false;
            networking.networkmanager.enable = lib.mkForce false; 
            services.udisks2.enable = lib.mkForce false;
            
            # Ensure WiFi tools are present
            environment.systemPackages = [ pkgs.wpa_supplicant pkgs.wireless-regdb ];
          })
        ];

        # aarch64
        minimal-aarch64 = mkSystem "aarch64-linux" [ ];

        # riscv64 (experimental)
        minimal-riscv64 = mkSystem "riscv64-linux" [ ];
      };

      # ────────────────────────────────────────────────────────────────
      #  Apps – short commands via  nix run .#<name>
      # ────────────────────────────────────────────────────────────────
      mkAppsFor = configName: cfg: let
        sys = cfg.config.system;
        pkgs = nixpkgs.legacyPackages.${sys}; # FIX: Define pkgs here
      in {
        "build-${configName}" = {
          type = "app";
          program = "${pkgs.writeShellScript "build-${configName}" ''
            set -euo pipefail
            echo -e "\033[1;34m→ Building NixOS config: ${configName}\033[0m"
            nix build .#nixosConfigurations.${configName}.config.system.build.toplevel \
              --show-trace --print-build-logs --keep-failed
            echo -e "\033[1;32mDone.\033[0m Path → $(readlink -f result)"
          ''}";
        };
        "dry-run-${configName}" = {
          type = "app";
          program = "${pkgs.writeShellScript "dry-${configName}" ''
            echo -e "\033[1;33m→ Dry-run evaluation of ${configName}\033[0m"
            nix eval --raw .#nixosConfigurations.${configName}.config.system.build.toplevel \
              --show-trace --impure 2>&1 | grep -v warning || true
          ''}";
        };
        "vm-${configName}" = {
          type = "app";
          program = "${pkgs.writeShellScript "vm-${configName}" ''
            set -euo pipefail
            echo -e "\033[1;35m→ Starting VM for ${configName}\033[0m"
            ${cfg.config.system.build.vm}/bin/run-${configName}-vm
          ''}";
        };
        "switch-${configName}" = {
          type = "app";
          program = "${pkgs.writeShellScript "switch-${configName}" ''
            set -euo pipefail
            echo -e "\033[1;32m→ Activating ${configName} on this machine\033[0m"
            sudo nixos-rebuild switch --flake .#${configName} --use-remote-sudo "$@"
          ''}";
        };
      };

      allApps = nixpkgs.lib.genAttrs
        (builtins.attrNames profiles)
        (name: mkAppsFor name profiles.${name});

    in {
      # NixOS Configurations
      nixosConfigurations = profiles;

      # Apps (Fixed merging logic)
      apps = nixpkgs.lib.genAttrs
        [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ]
        (sys: 
          let
            pkgs = nixpkgs.legacyPackages.${sys};
            systemApps = nixpkgs.lib.mergeAttrsList
              (map (p: allApps.${p} or {}) (builtins.attrNames profiles));
          in
          systemApps // {
            default = {
              type = "app";
              program = "${pkgs.writeShellScript "list-profiles" ''
                echo ""
                echo -e "\033[1mAvailable profiles:\033[0m"
                ${builtins.concatStringsSep "\n" (map (n: "  • ${n}") (builtins.attrNames profiles))}
                echo ""
                echo "Examples:"
                echo "  nix run .#build-minimal-x86_64"
                echo "  nix run .#build-iso-minimal    # Build the 512MB optimized ISO"
                echo "  nix run .#switch-minimal-x86_64"
                echo ""
              ''}";
            };
          }
        );
    };
}

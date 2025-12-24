{
  description = "Oligarchy NixOS Lite - Ultra-minimal NixOS for legacy hardware, VMs, ARM and RISC-V";

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
        specialArgs = { inherit inputs; };  # optional: pass inputs to modules if needed
        modules = [
          ./configuration-base.nix
        ] ++ extraModules;
      };

      profiles = {
        # x86_64
        minimal-x86_64 = mkSystem "x86_64-linux" [ ];
        gaming-x86_64  = mkSystem "x86_64-linux"  [ ./modules/gaming-profile.nix ];

        # aarch64
        minimal-aarch64 = mkSystem "aarch64-linux" [ ];
        gaming-aarch64  = mkSystem "aarch64-linux"  [ ./modules/gaming-profile.nix ];

        # riscv64 (experimental)
        minimal-riscv64 = mkSystem "riscv64-linux" [ ];
      };

      # ────────────────────────────────────────────────────────────────
      #  Apps – short commands via  nix run .#<name>
      # ────────────────────────────────────────────────────────────────
      mkAppsFor = configName: cfg: let
        sys = cfg.config.system;
      in {
        "build-${configName}" = {
          type = "app";
          program = "${pkgs.writeShellScript "build-${configName}" ''
            set -euo pipefail
            echo -e "\033[1;34m→ Building NixOS config: ${configName}\033[0m"
            nix build .#nixosConfigurations.${configName}.config.system.build.toplevel \
              --show-trace --print-build-logs --keep-failed
            echo -e "\033[1;32mDone. Path →\033[0m $(readlink -f result)"
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
      # Keep your original nixosConfigurations
      nixosConfigurations = profiles;

      # Merge all generated apps
      apps = nixpkgs.lib.genAttrs
        [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ]
        (sys: nixpkgs.lib.mergeAttrsList
          (map (p: allApps.${p} or {}) (builtins.attrNames profiles)));

      # Optional: default app = list available profiles
      apps.default = {
        type = "app";
        program = "${pkgs.writeShellScript "list-profiles" ''
          echo ""
          echo -e "\033[1mAvailable profiles:\033[0m"
          ${builtins.concatStringsSep "\n" (map (n: "  • ${n}") (builtins.attrNames profiles))}
          echo ""
          echo "Examples:"
          echo "  nix run .#build-minimal-x86_64"
          echo "  nix run .#vm-gaming-aarch64"
          echo "  nix run .#switch-gaming-x86_64     # (needs sudo)"
          echo ""
          echo "Or use ./switch-profile for an interactive menu"
        ''}";
      };
    };
}

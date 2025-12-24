# flake.nix
{
  description = "Oligarchy NixOS Lite - Ultra-minimal NixOS for legacy hardware, VMs, ARM and RISC-V";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # x86_64 profiles (full feature set)
      minimal-x86_64 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configuration-base.nix ];
      };

      gaming-x86_64 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration-base.nix
          ./modules/gaming-profile.nix
        ];
      };

      # aarch64 profiles (good native support for most FOSS games)
      minimal-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [ ./configuration-base.nix ];
      };

      gaming-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./configuration-base.nix
          ./modules/gaming-profile.nix
        ];
      };

      # riscv64 profile (experimental, minimal only)
      minimal-riscv64 = nixpkgs.lib.nixosSystem {
        system = "riscv64-linux";
        modules = [ ./configuration-base.nix ];
      };
    };
  };
}

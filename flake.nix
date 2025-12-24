# flake.nix (Updated for Architecture-Specific Safety)
{
  description = "Oligarchy NixOS Lite - Ultra-minimal NixOS with arch-aware configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # x86_64 - Full support
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

      # aarch64 - Good native support for FOSS gaming/OpenWebUI/Ollama (CPU mode)
      minimal-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [ ./configuration-base.nix ];
      };

      gaming-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./configuration-base.nix
          ./modules/gaming-profile.nix  # Native ARM builds for most FOSS games
        ];
      };

      # riscv64 - Experimental; minimal only (many packages fail; no official Ollama/gaming)
      minimal-riscv64 = nixpkgs.lib.nixosSystem {
        system = "riscv64-linux";
        modules = [ ./configuration-base.nix ];
      };
    };
  };
}

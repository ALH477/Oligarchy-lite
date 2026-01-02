# configuration-base.nix
{ config, pkgs, lib, inputs, ... }: { # FIX: Added 'inputs' here
  imports = [
    ./modules/kernel-optimizations.nix
    ./modules/networking.nix
    ./modules/audio.nix
    ./modules/bluetooth.nix
    ./modules/firewall.nix
    ./modules/webserver.nix
    ./modules/python.nix
    ./modules/agentic-local-ai.nix
    ./modules/dcf-community-node.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # ────────────────────────────────────────────────────────────
  # Core Configuration
  # ────────────────────────────────────────────────────────────
  
# Set to "manual" for Digital Ocean / Manual control
  custom.networking.mode = "manual";
  
  custom.audio.backend = "alsa";
  custom.bluetooth.enable = false;
  custom.firewall.mode = "disabled"; # We rely on module-specific firewall rules
  custom.webserver.mode = "none";
  custom.python.enable = false;

  # ────────────────────────────────────────────────────────────
  # DeMoD Community Node
  # ────────────────────────────────────────────────────────────
  custom.dcfCommunityNode = {
    enable = true;
    nodeId = "YOUR-REGISTERED-NODE-ID"; # <--- UPDATE THIS
    openFirewall = true;
  };

  # ────────────────────────────────────────────────────────────
  # Local AI Service
  # ────────────────────────────────────────────────────────────
  services.ollamaAgentic = {
    enable = false;
    preset = "heroic";
    acceleration = "vulkan";
    # advanced.rocm.gfxVersionOverride = "11.0.2";
    # FIX: Use square brackets for list
    models = [ "qwen3:0.6b-instruct-q5_K_M" "llama3.2:1b-instruct-q5_K_M" ]; 
  }; # FIX: Added closing brace

  # ────────────────────────────────────────────────────────────
  # System Basics
  # ────────────────────────────────────────────────────────────
  services.qemuGuest.enable = false;
  
  boot.initrd.availableKernelModules = [
    "virtio_net" "virtio_pci" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio"
  ];
  boot.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];

  services.xserver.enable = false;
  services.getty.autologinUser = "user";

  users.users.user = {
    isNormalUser = true;
    initialPassword = "changeme";
    extraGroups = [ "wheel" "docker" ]; # Added docker group
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    neovim htop file ranger toilet iw wpa_supplicant dhcpcd
    git
  ];

  # ────────────────────────────────────────────────────────────
  # Home Manager
  # ────────────────────────────────────────────────────────────
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.user = { pkgs, lib, ... }: {
    home.stateVersion = "25.11";
    home.file.".bashrc".text = ''
      print_menu() {
        clear
        toilet -f mono12 -F gay " OLIGARCHY NIXOS "
        echo
        echo "Status: DCF Node Active (Core 0)"
        echo "Type 'info' for stats, 'edit' for nvim"
        echo
      }
      PROMPT_COMMAND="print_menu"
      PS1="\n> "
      alias info='htop'
      alias edit='nvim'
      alias files='ranger'
      alias reboot='sudo systemctl reboot'
      alias off='sudo systemctl poweroff'
    '';
  };

  system.stateVersion = "25.11";
}

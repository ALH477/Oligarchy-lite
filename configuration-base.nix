# configuration-base.nix
{ config, pkgs, lib, ... }: {
  imports = [
    ./modules/kernel-optimizations.nix
    ./modules/networking.nix
    ./modules/audio.nix
    ./modules/bluetooth.nix
    ./modules/firewall.nix
    ./modules/webserver.nix
    ./modules/python.nix
    ./modules/agentic-local-ai.nix
    home-manager.nixosModules.home-manager
  ];

  # Default configuration values (minimal footprint)
  custom.networking.mode = "manual";
  custom.audio.backend = "alsa";
  custom.bluetooth.enable = false;
  custom.firewall.mode = "disabled";
  custom.webserver.mode = "none";
  custom.python.enable = false;
  custom.openwebui.enable = false;

# local ai
  heroic = {
      shmSize = "4gb";
      numParallel = 1;
      maxLoadedModels = 1;
      keepAlive = "4h";
      maxQueue = 64;
      memoryPressure = "0.85";
    };

  # VM guest support
  services.qemuGuest.enable = true;
  boot.initrd.availableKernelModules = [
    "virtio_net" "virtio_pci" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio"
  ];
  boot.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];

  # No graphical server by default
  services.xserver.enable = false;

  # Console auto-login
  services.getty.autologinUser = "user";

  users.users.user = {
    isNormalUser = true;
    initialPassword = "changeme";
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    neovim htop file ranger toilet iw wpa_supplicant dhcpcd
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.user = { pkgs, lib, ... }: {
    home.stateVersion = "25.11";

    home.file.".bashrc".text = ''
      print_menu() {
        clear
        toilet -f mono12 -F gay " OLIGARCHY NIXOS LITE "
        toilet -f smblock -F metal "Minimal Console"

        local intro_status="ON"
        [ -f ~/.no_intro ] && intro_status="OFF"

        echo
        echo "Auto-Intro: $intro_status (toggle with toggleintro + reboot)"
        echo
        echo "Type command:"
        echo "  info     System stats (htop)"
        echo "  edit     Text editor (nvim)"
        echo "  files    File browser (ranger)"
        echo "  scan     WiFi networks"
        echo "  wifi     Connect WiFi"
        echo "  disconnect Stop WiFi"
        echo "  reboot   Restart system"
        echo "  off      Shutdown"
        echo
        echo "Enable additional features via config + rebuild"
      }

      PROMPT_COMMAND="print_menu"
      PS1="\n> "

      alias info='htop'
      alias edit='nvim'
      alias files='ranger'

      alias scan='
        clear
        toilet -f mono12 -F gay " WIFI SCAN "
        IF=$(ip link | grep wl | awk -F: "{print \$2}" | tr -d " ")
        if [ -z "$IF" ]; then echo "No wireless interface found"; sleep 5; exit; fi
        echo "Scanning on $IF..."
        sudo iw dev "$IF" scan | grep SSID | sort -u
        echo
        echo "Use 'wifi' to connect"
        sleep 10
      '

      alias wifi='
        clear
        toilet -f mono12 -F gay " WIFI CONNECT "
        IF=$(ip link | grep wl | awk -F: "{print \$2}" | tr -d " ")
        if [ -z "$IF" ]; then echo "No wireless"; sleep 5; exit; fi
        read -p "SSID: " ssid
        read -s -p "Password (leave blank for open): " pass
        echo
        echo "network={" > /tmp/wpa.conf
        echo "  ssid=\"$ssid\"" >> /tmp/wpa.conf
        if [ -n "$pass" ]; then
          wpa_passphrase "$ssid" "$pass" >> /tmp/wpa.conf
        else
          echo "  key_mgmt=NONE" >> /tmp/wpa.conf
        fi
        echo "}" >> /tmp/wpa.conf
        sudo cp /tmp/wpa.conf /etc/wpa_supplicant.conf
        sudo chmod 600 /etc/wpa_supplicant.conf
        rm /tmp/wpa.conf
        sudo wpa_supplicant -B -i "$IF" -c /etc/wpa_supplicant.conf
        sudo dhcpcd "$IF"
        echo "Attempted connection. Check 'ip addr'"
        sleep 5
      '

      alias disconnect='
        clear
        toilet -f mono12 -F gay " WIFI STOP "
        sudo pkill wpa_supplicant
        sudo pkill dhcpcd
        echo "Disconnected"
        sleep 3
      '

      alias reboot='sudo systemctl reboot'
      alias off='sudo systemctl poweroff'
    '';
  };

  system.stateVersion = "25.11";
}

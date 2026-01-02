# modules/networking.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.custom.networking;
in
{
  options.custom.networking.mode = lib.mkOption {
    type = lib.types.enum [ "manual" "wpa" "networkmanager" ];
    default = "networkmanager";
    description = "Networking mode: manual (offline/lazy), wpa (auto wpa_supplicant), networkmanager (full auto/GUI).";
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [ wpa_supplicant dhcpcd iw ];
    }

    (lib.mkIf (cfg.mode == "manual") {
      networking.wireless.enable = false;
      networking.networkmanager.enable = false;
    })

    (lib.mkIf (cfg.mode == "wpa") {
      networking.wireless.enable = true;
      networking.dhcpcd.enable = true;
      networking.networkmanager.enable = false;
    })

    (lib.mkIf (cfg.mode == "networkmanager") {
      networking.networkmanager.enable = true;
      networking.wireless.enable = false;
    })
  ];
}

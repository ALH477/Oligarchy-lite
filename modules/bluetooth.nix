# modules/bluetooth.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.custom.bluetooth;
in
{
  options.custom.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support (hardware + console tools)";
    powerOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Power on Bluetooth adapter at boot.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = cfg.powerOnBoot;
    services.blueman.enable = false;
    environment.systemPackages = with pkgs; [ bluez bluez-tools ];
  };
}

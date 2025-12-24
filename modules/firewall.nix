# modules/firewall.nix
{ config, lib, ... }:

let
  cfg = config.custom.firewall;
in
{
  options.custom.firewall = {
    mode = lib.mkOption {
      type = lib.types.enum [ "disabled" "basic" "strict" ];
      default = "disabled";
    };
    extraAllowedTCPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [];
    };
    extraAllowedUDPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [];
    };
  };

  config = lib.mkIf (cfg.mode != "disabled") {
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = cfg.extraAllowedTCPPorts;
    networking.firewall.allowedUDPPorts = cfg.extraAllowedUDPPorts;
    networking.firewall.allowPing = lib.mkIf (cfg.mode == "basic") true;

    networking.firewall.extraCommands = lib.mkIf (cfg.mode == "strict") ''
      iptables -P INPUT DROP
      iptables -P FORWARD DROP
      iptables -P OUTPUT ACCEPT
      iptables -A INPUT -i lo -j ACCEPT
      iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    '';
  };
}

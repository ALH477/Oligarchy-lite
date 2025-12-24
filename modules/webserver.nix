# modules/webserver.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.custom.webserver;
in
{
  options.custom.webserver = {
    mode = lib.mkOption {
      type = lib.types.enum [ "none" "nginx" "caddy" "python" ];
      default = "none";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
    root = lib.mkOption {
      type = lib.types.path;
      default = "/var/www";
    };
    enableHTTPS = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkMerge [
    {
      fileSystems."/var/www" = lib.mkIf (cfg.mode != "none") {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "mode=755" ];
      };
    }

    (lib.mkIf (cfg.mode == "nginx") {
      services.nginx.enable = true;
      services.nginx.recommendedOptimisation = true;
      services.nginx.virtualHosts."localhost" = {
        listen = [ { addr = "0.0.0.0"; port = cfg.port; } ];
        root = cfg.root;
        locations."/".extraConfig = "autoindex on;";
      };
      networking.firewall.allowedTCPPorts = [ cfg.port ];
    })

    (lib.mkIf (cfg.mode == "caddy") {
      services.caddy.enable = true;
      services.caddy.virtualHosts."localhost:${toString cfg.port}".extraConfig = ''
        root * ${cfg.root}
        file_server
        encode gzip
      '';
      networking.firewall.allowedTCPPorts = [ cfg.port ] ++ (lib.optional cfg.enableHTTPS 443);
    })

    (lib.mkIf (cfg.mode == "python") {
      environment.systemPackages = [ pkgs.python3 ];
      home-manager.users.user = { ... }: {
        home.file.".bashrc".text = lib.mkAfter ''
          alias serve='python3 -m http.server ${toString cfg.port}'
          alias servesys='python3 -m http.server --directory ${cfg.root} ${toString cfg.port}'
        '';
      };
      networking.firewall.allowedTCPPorts = [ cfg.port ];
    })
  ];
}

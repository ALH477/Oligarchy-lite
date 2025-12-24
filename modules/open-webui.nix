# modules/open-webui.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.custom.openwebui;
in
{
  options.custom.openwebui = {
    enable = lib.mkEnableOption "Open WebUI with Ollama (LLM interface)";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
    ollamaAccelerate = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    adminPassword = lib.mkOption {
      type = lib.types.str;
      default = "changeme";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama.enable = true;
    services.ollama.acceleration = lib.mkIf cfg.ollamaAccelerate "vulkan";
    services.ollama.host = "0.0.0.0";

    systemd.services.openwebui = {
      description = "Open WebUI LLM Interface";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "ollama.service" ];
      environment = {
        OLLAMA_API_BASE = "http://127.0.0.1:11434";
        ADMIN_PASSWORD = cfg.adminPassword;
      };
      serviceConfig = {
        ExecStart = "${pkgs.open-webui}/bin/open-webui serve --port ${toString cfg.port}";
        DynamicUser = true;
        Restart = "always";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    environment.systemPackages = with pkgs; [ links2 ];

    home-manager.users.user = { ... }: {
      home.file.".bashrc".text = lib.mkAfter ''
        alias webui='links2 http://localhost:${toString cfg.port}'
        alias webui-log='journalctl -u openwebui -f'
        echo "  webui     Open WebUI (text browser)"
        echo "  webui-log Tail Open WebUI logs"
      '';
    };
  };
}

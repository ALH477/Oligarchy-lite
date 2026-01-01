# modules/dcf-community-node.nix
# NixOS module for running a production-hardened DeMoD Community DCF-SDK node
# Integrates seamlessly into Oligarchy-Lite NixOS (or any NixOS flake)
#
# Usage in your flake/configuration.nix:
#
#   custom.dcfCommunityNode = {
#     enable = true;
#     nodeId = "your-registered-node-id";  # Required after registration
#     openFirewall = true;                 # Optional, defaults to true
#   };

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.dcfCommunityNode;

  configToml = pkgs.lib.generators.toTOML {} {
    network = {
      gateway_url = "https://dcf.demod.ltd";
      discovery_mode = "central";
      node_type = "community";
    };

    server = {
      bind_udp = "0.0.0.0:7777";
      bind_grpc = "0.0.0.0:50051";
    };

    performance = {
      target_hz = 125;
      shim_mode = "universal";
    };

    node = {
      id = cfg.nodeId;
    };
  };

in {
  options.custom.dcfCommunityNode = {
    enable = mkEnableOption "DeMoD Community DCF-SDK Node (voluntary mesh contributor)";

    nodeId = mkOption {
      type = types.str;
      default = "";
      description = ''
        Your unique node ID obtained from https://dcf.demod.ltd/register
        or Discord. This is required for the node to join the mesh.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically open required ports in the firewall";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.nodeId != "";
        message = "custom.dcfCommunityNode.nodeId must be set to your registered node ID";
      }
    ];

    warnings = optional (cfg.nodeId == "") ''
      custom.dcfCommunityNode.nodeId is empty – the node will start but won't connect to the mesh.
      Register at https://dcf.demod.ltd/register and set the ID.
    '';

    # Enable Docker (preferred backend for exact capability/ulimit matching)
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    # Declarative container (OCI-compatible, uses Docker backend)
    virtualisation.oci-containers = {
      backend = "docker";
      containers.dcf-sdk = {
        image = "alh477/dcf-rs:latest";
        autoStart = true;
        ports = [
          "7777:7777/udp"
          "50051:50051/tcp"
        ];

        environment = {
          DCF_CONFIG = "/etc/dcf/dcf_config.toml";
          RUST_LOG = "info";
          RUST_BACKTRACE = "1";
        };

        volumes = [
          "/etc/dcf-community-config:/etc/dcf:ro"
        ];

        extraOptions = [
          "--cpuset-cpus=0"                  # Pin to core 0 (adjust if needed)
          "--cap-add=SYS_NICE"
          "--cap-add=NET_RAW"
          "--cap-add=IPC_LOCK"
          "--ulimit=rtprio=99:99"
          "--ulimit=memlock=-1:-1"
          "--ulimit=nofile=65536:65536"
          "--cpus=1.0"
          "--memory=512m"
          "--memory-reservation=256m"
          "--read-only"
          "--tmpfs=/tmp:size=64M"
          "--tmpfs=/run:size=16M"
          "--security-opt=no-new-privileges:true"
          "--log-driver=json-file"
          "--log-opt=max-size=10m"
          "--log-opt=max-file=5"
          "--health-cmd=/usr/local/bin/dcf status"
          "--health-interval=30s"
          "--health-timeout=10s"
          "--health-retries=5"
          "--health-start-period=20s"
        ];
      };
    };

    # Declarative config file (reproducible, survives rebuilds)
    environment.etc."dcf-community-config/dcf_config.toml" = {
      mode = "0444";
      text = configToml;
    };

    # Firewall integration (respects Oligarchy-Lite's custom.firewall if present)
    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPorts = [ 7777 ];
      allowedTCPPorts = [ 50051 ];
    };

    # Optional: Systemd hardening for the container unit
    systemd.services."docker-dcf-sdk" = {
      serviceConfig = {
        Restart = "always";
        RestartSec = "10";
      };
    };
  };
}

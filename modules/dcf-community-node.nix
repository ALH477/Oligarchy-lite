# modules/dcf-community-node.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.dcfCommunityNode;
  
  # SAFER: Use Nix's built-in TOML generator to handle escaping correctly
  configFile = pkgs.writeText "dcf_config.toml" (lib.generators.toTOML {
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
  });

in {
  options.custom.dcfCommunityNode = {
    enable = mkEnableOption "DeMoD Community DCF-SDK Node";
    
    nodeId = mkOption {
      type = types.str;
      default = "";
      description = "Your unique node ID from https://dcf.demod.ltd/register";
    };

    # NEW: Optional CPU pinning (Defaults to null/disabled for safety)
    cpuSet = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "0-1";
      description = "Specific CPU cores to pin the container to (e.g., '0' or '2-3'). Leave null to let OS schedule.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically open UDP/7777 and TCP/50051";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.nodeId != "";
        message = "dcfCommunityNode: You must provide a valid 'nodeId' to participate.";
      }
    ];

    # Enable Docker automatically if this module is used
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
      autoPrune.dates = "weekly";
    };

    # The Container Definition
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
          # Enable backtrace only if something goes wrong
          RUST_BACKTRACE = "1";
        };

        # Mount the generated config file
        volumes = [
          "${configFile}:/etc/dcf/dcf_config.toml:ro"
        ];

        extraOptions = [
          # Hardening
          "--cap-add=SYS_NICE"
          "--cap-add=NET_RAW"
          "--cap-add=IPC_LOCK"
          "--ulimit=rtprio=99:99"
          "--ulimit=memlock=-1:-1"
          "--ulimit=nofile=65536:65536"
          "--security-opt=no-new-privileges:true"
          "--read-only"
          "--tmpfs=/tmp:size=64M"
          
          # Resources
          "--cpus=1.0"
          "--memory=512m"
          "--memory-reservation=256m"
          
          # Logging (Rotate logs so the minimalist disk doesn't fill up)
          "--log-driver=json-file"
          "--log-opt=max-size=10m"
          "--log-opt=max-file=3"

          # HEALTHCHECK: Changed to a safer 'listening' check
          # If the binary doesn't have 'status', this ensures it's actually bound to the port
          "--health-cmd=netstat -uln | grep :7777 || exit 1"
          "--health-interval=30s"
          "--health-timeout=5s"
          "--health-retries=3"
          "--health-start-period=10s"
        ] ++ lib.optional (cfg.cpuSet != null) "--cpuset-cpus=${cfg.cpuSet}";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPorts = [ 7777 ];
      allowedTCPPorts = [ 50051 ];
    };
  };
}

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.dcfCommunityNode;

  # Stable TOML generation for DCF Configuration
  tomlFormat = pkgs.formats.toml {};
  
  # Configuration file generation with corrected Shim/Bridge logic
  configFile = tomlFormat.generate "dcf_config.toml" {
    # POLYGLOT CONFIG: Defines ID in all expected locations for compatibility
    node_id = cfg.nodeId;
    id = cfg.nodeId;
    mode = "community";

    # SHIM CONFIGURATION
    shim = {
      # CRITICAL FIX: Point target to internal loopback to avoid external feedback loops.
      # This relays translated game traffic to the main node process internally.
      target = "127.0.0.1:7777"; 
    };

    network = {
      gateway_url = "http://api.demod.ltd";
      discovery_mode = "central";
      node_type = "community";
    };

    server = {
      # Main HydraMesh Binary Protocol (High Performance)
      bind_udp = "0.0.0.0:7777";
      # gRPC Control Interface
      bind_grpc = "0.0.0.0:50051";
      # Shim/Bridge Interface (JSON/Legacy Support for Games)
      # Must explicitly listen on 0.0.0.0 to accept Docker proxy traffic
      bind_shim = "0.0.0.0:8888"; 
    };

    performance = {
      target_hz = 125;
      # Bridge mode enables bidirectional traffic for game clients (Zandronum, etc.)
      shim_mode = "bridge"; 
    };

    # Nested blocks for safety/legacy SDK compatibility
    node = { id = cfg.nodeId; node_id = cfg.nodeId; };
    dcf = { node_id = cfg.nodeId; };
  };

in {
  options.custom.dcfCommunityNode = {
    enable = mkOption {
      type = types.bool;
      default = cfg.nodeId != "";
      description = "Enable the DCF Node service.";
    };

    nodeId = mkOption {
      type = types.str;
      default = "alh477";
      description = "Node ID from the DCF dashboard.";
    };

    cpuSet = mkOption { 
      type = types.nullOr types.str; 
      default = null;
      description = "Specific CPU cores to pin the real-time process to (e.g. '0-3').";
    };

    openFirewall = mkOption { 
      type = types.bool; 
      default = true;
      description = "Automatically open required UDP/TCP ports in the firewall.";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    virtualisation.oci-containers = {
      backend = "docker";
      
      containers.dcf-sdk = {
        image = "alh477/dcf-rs:latest";
        autoStart = true;
        
        # Production CMD: Point directly to the generated config
        cmd = [ "--config" "/tmp/config.toml" ];
        
        # EXPOSED PORTS
        # 7777: HydraMesh Binary (Node-to-Node)
        # 50051: gRPC (Control/Dashboard)
        # 8888: Shim Bridge (Game Client Connection) - ADDED
        ports = [ 
          "7777:7777/udp" 
          "50051:50051/tcp"
          "8888:8888/udp" 
        ];
        
        environment = { 
          RUST_LOG = "info";
          # Force bridge mode via ENV as a fail-safe
          DCF_SHIM_MODE = "bridge"; 
        };

        volumes = [
          # Mount generated config to /tmp to bypass read-only root permission locks
          "${configFile}:/tmp/config.toml:ro"
        ];

        # REAL-TIME PERFORMANCE OPTIMIZATIONS
        extraOptions = [
          "--cap-add=SYS_NICE"      # Allow thread prioritization
          "--cap-add=NET_RAW"       # Allow raw socket access
          "--cap-add=IPC_LOCK"      # Prevent memory swapping
          "--ulimit=rtprio=99:99"   # Real-time priority limit
          "--ulimit=memlock=-1:-1"  # Unlimited memory locking
          "--security-opt=no-new-privileges:true"
          "--cpus=1.0"              # Reserved CPU capacity
          "--memory=512m"           # Memory ceiling
        ] ++ lib.optional (cfg.cpuSet != null) "--cpuset-cpus=${cfg.cpuSet}";
      };
    };

    # FIREWALL CONFIGURATION
    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPorts = [ 
        7777 # Binary Protocol
        8888 # Shim/Game Protocol - ADDED
      ];
      allowedTCPPorts = [ 
        50051 # gRPC
      ];
    };
  };
}

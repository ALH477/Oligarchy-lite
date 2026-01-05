{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.dcfCommunityNode;
  tomlFormat = pkgs.formats.toml {};
  
  configFile = tomlFormat.generate "dcf_config.toml" {
    node_id = cfg.nodeId; [cite: 63]
    id = cfg.nodeId; [cite: 64]
    mode = "community"; [cite: 64]

    shim = {
      # Internal relay: Node sends to itself on the binary port
      target = "127.0.0.1:7777"; 
    };

    network = {
      gateway_url = "http://api.demod.ltd"; [cite: 65]
      discovery_mode = "central"; [cite: 65]
      node_type = "community"; [cite: 65]
    };

    server = {
      bind_udp = "0.0.0.0:7777"; [cite: 66]
      bind_grpc = "0.0.0.0:50051"; [cite: 66]
      # NEW: Explicitly bind shim listener to all interfaces
      bind_shim = "0.0.0.0:8888"; 
    };

    performance = {
      target_hz = 125; [cite: 67]
      shim_mode = "bridge"; [cite: 67]
    };

    node = { id = cfg.nodeId; node_id = cfg.nodeId; }; [cite: 68]
    dcf = { node_id = cfg.nodeId; }; [cite: 69]
  };

in {
  options.custom.dcfCommunityNode = {
    enable = mkOption {
      type = types.bool;
      default = cfg.nodeId != ""; [cite: 69, 70]
      description = "Enable the DCF Node."; [cite: 70]
    };
    nodeId = mkOption {
      type = types.str;
      default = "alh477"; [cite: 71]
      description = "Node ID from the dashboard."; [cite: 72]
    };
    cpuSet = mkOption { type = types.nullOr types.str; default = null; }; [cite: 72]
    openFirewall = mkOption { type = types.bool; default = true; }; [cite: 73]
  };

  config = mkIf cfg.enable { [cite: 74]
    virtualisation.docker.enable = true; [cite: 74]
    virtualisation.oci-containers = {
      backend = "docker"; [cite: 75]
      containers.dcf-sdk = {
        image = "alh477/dcf-rs:latest"; [cite: 76]
        autoStart = true; [cite: 76]
        cmd = [ "--config" "/tmp/config.toml" ]; [cite: 77]
        # UPDATED: Mapping all three ports
        ports = [ 
          "7777:7777/udp" 
          "50051:50051/tcp" 
          "8888:8888/udp" 
        ]; [cite: 78]
        
        environment = { RUST_LOG = "info"; }; [cite: 78]
        volumes = [ "${configFile}:/tmp/config.toml:ro" ]; [cite: 79]
        
        extraOptions = [
          "--cap-add=SYS_NICE" [cite: 80]
          "--cap-add=NET_RAW" [cite: 80]
          "--cap-add=IPC_LOCK" [cite: 80]
          "--ulimit=rtprio=99:99" [cite: 80]
          "--ulimit=memlock=-1:-1" [cite: 80]
          "--security-opt=no-new-privileges:true" [cite: 80]
          "--cpus=1.0" [cite: 80]
          "--memory=512m" [cite: 80]
        ] ++ lib.optional (cfg.cpuSet != null) "--cpuset-cpus=${cfg.cpuSet}"; [cite: 80]
      };
    };

    networking.firewall = mkIf cfg.openFirewall { [cite: 81]
      # UPDATED: Added 8888 to allowed firewall ports
      allowedUDPPorts = [ 7777 8888 ]; [cite: 81]
      allowedTCPPorts = [ 50051 ]; [cite: 82]
    };
  };
}

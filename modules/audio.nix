{ config, lib, pkgs, ... }:

let
  cfg = config.custom.audio;
in
{
  options.custom.audio = {
    backend = lib.mkOption {
      type = lib.types.enum [ "alsa" "pulseaudio" "pipewire" "none" ];
      default = "pipewire";
      description = "Audio backend to use";
    };
  };

  config = lib.mkMerge [
    # 1. ALSA (Minimal)
    (lib.mkIf (cfg.backend == "alsa") {
      services.pipewire.enable = false;
      services.pulseaudio.enable = false;
      environment.systemPackages = [ pkgs.alsa-utils ];
    })

    # 2. PulseAudio (Legacy)
    (lib.mkIf (cfg.backend == "pulseaudio") {
      services.pipewire.enable = false;
      services.pulseaudio.enable = true;
      services.pulseaudio.support32Bit = true;
      hardware.pulseaudio.package = pkgs.pulseaudioFull;
    })

    # 3. PipeWire (Modern Standard)
    (lib.mkIf (cfg.backend == "pipewire") {
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    })

    # 4. None (Silent)
    (lib.mkIf (cfg.backend == "none") {
      services.pipewire.enable = false;
      services.pulseaudio.enable = false;
    })
  ];
}

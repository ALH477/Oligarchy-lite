# modules/audio.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.custom.audio;
in
{
  options.custom.audio = {
    backend = lib.mkOption {
      type = lib.types.enum [ "alsa" "jack" "pipewire" ];
      default = "alsa";
    };
    lowLatency = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkMerge [
    {
      sound.enable = true;
      hardware.pulseaudio.enable = false;
    }

    (lib.mkIf (cfg.backend == "alsa") {
      services.pipewire.enable = false;
      services.jack.enable = false;
    })

    (lib.mkIf (cfg.backend == "jack") {
      services.jack.jackd.enable = true;
      services.jack.jackd.extraOptions = lib.optional cfg.lowLatency [ "-P" "95" "-r" ];
      security.rtkit.enable = true;
      users.users.user.extraGroups = [ "audio" "jackaudio" ];
    })

    (lib.mkIf (cfg.backend == "pipewire") {
      services.pipewire.enable = true;
      services.pipewire.alsa.enable = true;
      services.pipewire.alsa.support32Bit = true;
      services.pipewire.pulse.enable = true;
      services.pipewire.jack.enable = true;
      services.pipewire.lowLatency.enable = cfg.lowLatency;
    })
  ];
}

# modules/kernel-optimizations.nix
{ config, pkgs, lib, ... }: {
  boot.kernelPackages = lib.mkMerge [
    (lib.mkIf (pkgs.stdenv.hostPlatform.isx86_64) pkgs.linuxPackages_zen)
    (lib.mkIf (!pkgs.stdenv.hostPlatform.isx86_64) pkgs.linuxPackages_latest)
  ];

  boot.kernelParams = [
    "mitigations=off"
    "threadirqs"
    "nowatchdog"
    "quiet"
    "loglevel=3"
    "rd.systemd.show_status=auto"
    "cpufreq.default_governor=performance"
    "iomem=relaxed"
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
    "nmi_watchdog=0"
    "processor.max_cstate=1"
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 15;
    "vm.watermark_scale_factor" = 200;
    "kernel.sched_autogroup_enabled" = 0;
    "kernel.sched_child_runs_first" = 1;
    "kernel.sched_migration_cost_ns" = 500000;
    "kernel.pid_max" = 65536;
    "fs.file-max" = 2097152;
  };

  # FIXED: Use hostPlatform.isRiscV (Capital V)
  powerManagement.cpuFreqGovernor = lib.mkIf (!pkgs.stdenv.hostPlatform.isRiscV) "performance";
}

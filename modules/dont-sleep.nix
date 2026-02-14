{
  config,
  pkgs,
  lib,
  ...
}:

{

  systemd.targets.sleep.enable = lib.mkForce false;
  systemd.targets.suspend.enable = lib.mkForce false;
  systemd.targets.hibernate.enable = lib.mkForce false;
  systemd.targets.hybrid-sleep.enable = lib.mkForce false;

  boot.kernelParams = lib.mkAfter [
    "intel_idle.max_cstate=0"
    "processor.max_cstate=1"
    "idle=nomwait"
  ];

  systemd.services.no-sleep = {
    enable = true;
    description = "Prevent system sleep for gaming server";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.systemd}/bin/systemd-inhibit \
          --what=sleep:idle:handle-lid-switch \
          --who="gaming-server" \
          --why="Always-on Sunshine + Steam VM" \
          ${pkgs.coreutils}/bin/sleep infinity
      '';
      Restart = "always";
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}

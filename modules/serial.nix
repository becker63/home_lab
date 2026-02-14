{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot.kernelParams = lib.mkAfter [
    "console=ttyS0,115200n8"
    "console=tty0"
    "earlycon=uart,io,0x3f8,115200"
    "loglevel=7"
    "systemd.log_target=console"
    "systemd.log_level=debug"
  ];

  boot.initrd.verbose = lib.mkDefault true;
  boot.plymouth.enable = lib.mkDefault false;

  systemd.services."serial-getty@ttyS0" = {
    enable = true;
    wantedBy = [ "getty.target" ];
    serviceConfig.ExecStart = lib.mkForce "${pkgs.systemd}/bin/agetty --autologin root ttyS0 115200";
  };
}

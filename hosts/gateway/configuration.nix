{
  modulesPath,
  lib,
  pkgs,
  ...
}@args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/disk-config.nix
    ../../modules/nix-settings.nix
    ../../modules/serial.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "tailscale-gateway";
  networking.networkmanager.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.nat = {
    enable = true;
    externalInterface = "ens18"; # Proxmox default bridge NIC
    internalInterfaces = [ "tailscale0" ];
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
    authKeyFile = "/etc/tailscale-authkey";
    extraUpFlags = [
      "--advertise-routes=192.168.0.0/24"
    ];
  };

  environment.systemPackages = with pkgs; [
    pciutils
    tailscale
  ];

  system.stateVersion = "24.05";
}

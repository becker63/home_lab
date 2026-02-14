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
    ../../modules/dont-sleep.nix
  ];

  boot.kernelParams = [
    "i915.enable_guc=3"
    "i915.force_probe=56a6"
    "i915.enable_dc=0"
    "i915.enable_psr=0"
  ];

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  boot.kernel.sysctl = {
    "kernel.split_lock_mitigate" = 0;
    "kernel.nmi_watchdog" = 0;
    "kernel.sched_bore" = "1";
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # BOOT
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # SSH
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # NETWORK
  networking.networkmanager.enable = true;

  # INTEL ARC GPU SUPPORT
  services.xserver.videoDrivers = [ "modesetting" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  ############################
  # STEAMOS (JOVIAN)
  ############################

  jovian = {
    steam.enable = true;
    steam.autoStart = true;
    steam.user = "steamos";
    steamos.useSteamOSConfig = true;
    hardware.has.amd.gpu = false;
    steam.desktopSession = "gamescope-wayland";
  };

  ############################
  # REQUIRED SYSTEM SERVICES
  ############################

  services.seatd.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  ############################
  # USERS
  ############################

  users.users.steamos = {
    isNormalUser = true;
    description = "SteamOS";
    extraGroups = [
      "video"
      "audio"
      "seat"
      "networkmanager"
      "input"
    ];
    password = "steamos";
  };

  ############################
  # TOOLS
  ############################

  environment.systemPackages = with pkgs; [
    pciutils
    mesa
    vulkan-tools
    intel-gpu-tools
  ];

  system.stateVersion = "24.05";
}

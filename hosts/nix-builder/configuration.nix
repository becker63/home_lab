{ config, pkgs, ... }:
{
  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };

  networking.hostName = "nix-builder";

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOLf+qV/gwORnv7FGIusYHWHHlofZLkwTuUmfU3aWyp colmena-laptop"
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [ "root" ];
      max-jobs = "auto";
      cores = 0;

      # THIS enables 32bit builds
      extra-platforms = [ "i686-linux" ];

      system-features = [
        "kvm"
        "big-parallel"
        "nixos-test"
      ];
    };

    buildMachines = [
      {
        hostName = "nix-builder";
        system = "x86_64-linux";
        sshUser = "root";
        sshKey = "/root/.ssh/authorized_keys";
        maxJobs = 16;
        speedFactor = 2;

        supportedFeatures = [
          "kvm"
          "big-parallel"
          "nixos-test"
        ];
      }
    ];

    distributedBuilds = true;
  };

  services.nix-serve = {
    enable = true;
    port = 5000;
    secretKeyFile = "/etc/nix/cache-priv-key.pem";
  };

  networking.firewall.allowedTCPPorts = [
    22
    5000
  ];

  environment.systemPackages = with pkgs; [
    git
    htop
    curl
  ];

  system.stateVersion = "25.05";
}

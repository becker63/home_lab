{ config, lib, ... }:

{
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  nix = {
    distributedBuilds = true;

    buildMachines = [
      {
        hostName = "192.168.0.102";
        sshUser = "root";
        system = "x86_64-linux";
        maxJobs = 16;
        speedFactor = 2;
        supportedFeatures = [
          "kvm"
          "big-parallel"
          "nixos-test"
        ];
      }
    ];

    settings = lib.mkMerge [
      {
        substituters = [ "http://192.168.0.102:5000" ];
        trusted-public-keys = [
          "nix-builder:vBW54yytRLJ2RSQDtIT5wExXfSMzzmnLTk+sMyeTAfg="
        ];
        builders-use-substitutes = true;
      }

      {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      }
    ];
  };

  users.users.root.initialPassword = "jidw";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOLf+qV/gwORnv7FGIusYHWHHlofZLkwTuUmfU3aWyp colmena-laptop"
  ];
}

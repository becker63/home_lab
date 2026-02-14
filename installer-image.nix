{ pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ./modules/nix-settings.nix
    ./modules/serial.nix
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  users.users.root = {
    initialPassword = pkgs.lib.mkForce "jidw";
    initialHashedPassword = pkgs.lib.mkForce null;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  environment.systemPackages = with pkgs; [
    git
    curl
    just
  ];

  system.stateVersion = "23.11";
}

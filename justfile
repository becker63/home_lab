deploy:
    nix run github:nix-community/nixos-anywhere -- --build-on local --flake .#gateway root@192.168.0.132

{
  description = "Home lab - Colmena controlled NixOS builder + Gaming VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    colmena.url = "github:zhaofengli/colmena";
    flake-utils.url = "github:numtide/flake-utils";

    # nixos-anywhere + disk automation
    disko.url = "github:nix-community/disko";

    # Gaming stack
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      colmena,
      flake-utils,
      disko,
      chaotic,
      jovian,
      nixos-generators,
      ...
    }:
    let
      system = "x86_64-linux";

      gamingModules = [
        disko.nixosModules.disko
        chaotic.nixosModules.default
        jovian.nixosModules.default
        ./hosts/gaming/configuration.nix
      ];
    in
    {
      packages.${system}.installer-iso = nixos-generators.nixosGenerate {
        system = system;
        format = "iso";
        modules = [
          ./installer-image.nix
        ];
      };

      nixosConfigurations = {
        gaming = nixpkgs.lib.nixosSystem {
          system = system;
          modules = gamingModules;
        };

        gateway = nixpkgs.lib.nixosSystem {
          system = system;
          modules = [
            disko.nixosModules.disko
            ./hosts/gateway/configuration.nix
          ];
        };
      };

      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = import nixpkgs {
            system = system;
            overlays = [ ];
          };
        };

        gaming =
          { pkgs, ... }:
          {
            deployment = {
              targetHost = "192.168.0.197";
              targetUser = "root";
              sshOptions = [
                "-i"
                "/home/becker/.ssh/colmena"
              ];
            };

            imports = gamingModules;
          };

        gateway =
          { pkgs, ... }:
          {
            deployment = {
              targetHost = "192.168.0.132";
              targetUser = "root";
              sshOptions = [
                "-i"
                "/home/becker/.ssh/colmena"
              ];
            };

            imports = [
              disko.nixosModules.disko
              ./hosts/gateway/configuration.nix
            ];
          };

        # --- Builder node ---
        builder =
          {
            name,
            nodes,
            pkgs,
            ...
          }:
          {
            deployment = {
              targetHost = "192.168.0.102";
              targetUser = "root";
              buildOnTarget = true;
              sshOptions = [
                "-i"
                "/home/becker/.ssh/colmena"
              ];
            };

            imports = [
              ./hosts/nix-builder/configuration.nix
              ./hosts/nix-builder/hardware-configuration.nix
            ];
          };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            colmena.packages.${system}.colmena
            pkgs.just
          ];
        };
      }
    );
}

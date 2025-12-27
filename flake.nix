{
  description = "Nix-based configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/v1.12.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cli = {
      url = "github:nix-community/nixos-cli";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-generators,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (lib.nixsys.pub) forEachSystem;

      lib = nixpkgs.lib.extend (
        final: _prev: {
          nixsys = import ./lib {
            inherit inputs outputs;
            lib = final;
          };
        }
      );

      forEachSupportedSystem = forEachSystem [
        "x86_64-linux"
        "aarch64-linux"
      ];

      user = {
        name = "user";
        full-name = "User Example";
        email = "example@email.com";
        shell = "bash";
        location = {
          city = "Reykjavik";
          latitude = 64.13;
          longitude = -21.56;
        };
        timezone = "UTC";
      };
    in
    {
      lib = lib.nixsys.pub;

      overlays = import ./overlays { inherit inputs; };

      nixosModules = import ./modules/os/mod.nix { inherit inputs outputs lib; };

      homeManagerModules = import ./modules/home/mod.nix { inherit inputs outputs lib; };

      packages = forEachSupportedSystem (
        { pkgs }:
        import ./packages { inherit pkgs; }
        // {
          workstation-qcow = nixos-generators.nixosGenerate {
            inherit lib;
            inherit (pkgs.stdenv.hostPlatform) system;
            format = "qcow-efi";
            specialArgs = {
              inherit
                inputs
                outputs
                lib
                user
                ;
              hostname = "workstation-qemu";
            };
            modules = [
              inputs.sops-nix.nixosModules.sops
              outputs.nixosModules.nixsys
              {
                nix.registry.nixpkgs.flake = nixpkgs;
                virtualisation.vmVariant.virtualisation = {
                  diskSize = 80 * 1024;
                  memSize = 8 * 1024;
                  writableStoreUseTmpfs = false;
                };
              }
              ./examples/machines/workstation-qemu/hardware.nix
              ./examples/machines/workstation-qemu/secrets.nix
              ./examples/machines/workstation-qemu/os.nix
            ];
          };
        }
      );

      # NixOS configuration examples.
      # usages:
      #   - nix build .#nixosConfigurations.{name}.config.system.build.toplevel
      #   - nix run .#build-machine -- {name}
      nixosConfigurations = {
        workstation-qemu = lib.nixsys.mkMachine {
          inherit user;
          hostname = "workstation-qemu";
          modules = [ ./examples/machines/workstation-qemu ];
        };
      };

      # Home configuration examples.
      # usage: home-manager build --flake .#example
      homeConfigurations = {
        headless = lib.nixsys.mkHome {
          inherit user;
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
          modules = [ { nixsys.home.profile.personal.enable = true; } ];
        };
      };

      apps = forEachSupportedSystem (
        { pkgs }:
        {
          build-machine =
            let
              script-pkg = pkgs.writeShellScriptBin "build-machine" ''
                set -e

                if [ -z "''${1}" ]; then
                  ${pkgs.coreutils}/bin/echo "Usage: nix run .#build-machine -- <nixosConfiguration>"
                  exit 1
                fi

                CONFIG="$1"

                ${pkgs.coreutils}/bin/echo "Building machine: ''$CONFIG"

                nix build ".#nixosConfigurations.''${CONFIG}.config.system.build.toplevel"

                ${pkgs.coreutils}/bin/echo "Build complete. See ./result"
              '';
            in
            {
              type = "app";
              program = "${script-pkg}/bin/build-machine";
            };

          build-home =
            let
              script-pkg = pkgs.writeShellScriptBin "build-home" ''
                set -e

                if [ -z "''${1}" ]; then
                  ${pkgs.coreutils}/bin/echo "Usage: nix run .#build-home -- <homeConfiguration>"
                  exit 1
                fi

                CONFIG="$1"

                ${pkgs.coreutils}/bin/echo "Building home: ''$CONFIG"

                ${pkgs.home-manager}/bin/home-manager build --flake ".#''${CONFIG}"

                ${pkgs.coreutils}/bin/echo "Build complete. See ./result"
              '';
            in
            {
              type = "app";
              program = "${script-pkg}/bin/build-home";
            };
        }
      );

      # Flake conveniences.
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = [
              pkgs.age
              pkgs.home-manager
              pkgs.sops
              pkgs.ssh-to-age

              pkgs.deadnix
              pkgs.nixfmt-rfc-style
              pkgs.statix
            ];
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt-rfc-style);
    };
}

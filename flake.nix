{
  description = "Nix-based configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cli = {
      url = "github:nix-community/nixos-cli/0.15.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
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

      packages = forEachSupportedSystem ({ pkgs }: import ./packages { inherit pkgs; });

      # NixOS configuration examples.
      # usages:
      #   - nix build .#nixosConfigurations.{name}.config.system.build.toplevel
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
            ];
          };

          pkg-psc =
            let
              pkg = pkgs.callPackage ./packages/psc { };
              python = builtins.elemAt (builtins.filter (p: p.pname == "python3") pkg.propagatedBuildInputs) 0;

              # So that the source file has the highest precedence and we can do live edits.
              psc = pkgs.writeShellScriptBin "psc" ''exec ${python}/bin/python3 -m psc "$@"'';
            in
            pkgs.mkShell {

              nativeBuildInputs = pkg.propagatedBuildInputs ++ pkg.propagatedNativeBuildInputs;

              packages = [ psc ];

              shellHook = ''
                if [[ -d "$PWD/src/psc" ]]; then
                  export PYTHONPATH="$PWD/src''${PYTHONPATH:+:$PYTHONPATH}"
                elif [[ -d "$PWD/packages/psc/src" ]]; then
                  export PYTHONPATH="$PWD/packages/psc/src''${PYTHONPATH:+:$PYTHONPATH}"
                fi
              '';
            };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}

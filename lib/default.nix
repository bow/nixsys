# Credit: https://github.com/thursdaddy/nixos-config/blob/58b3afe03aaf5d8b76806106846223548f4a3ff6/lib/default.nix
{
  lib,
  inputs,
  outputs,
  ...
}:
rec {
  # Publicly-exported functions.
  pub = { inherit forEachSystem mkMachine mkHome; };

  /**
    Loop over the given systems to apply the given functions that use nixpkgs for that system.

    # Example

    ```nix
    forEachSystem [ "x86-64_linux" "aarch64-linux" ] ({ pkgs }: { default = pkgs.mkShell { ... }; })
    => ...
    ```

    # Type

    ```
    forEachSystem :: [ String ] -> (AttrSet -> Any) -> Any
    ```

    # Arguments

    **systems**
    : A list of sytems from which pkgs will be produced.

    **f**
    : The function to apply to each system-specialized pkgs.
  */
  forEachSystem =
    systems: f: lib.genAttrs systems (system: f { pkgs = inputs.nixpkgs.legacyPackages.${system}; });

  /**
    Create a nixos system with the given main user and hardware module on the given host module.
    The hostname defaults to the module name.

    # Example

    ```nix
    mkMachine {
      user = {
        name = "default";
        full-name = "Default User";
        email = "default@email.com";
        location = {
          city = "Reykjavik";
          latitude = 64.13;
          longitude = -21.89;
        };
        timezone = "UTC";
      };
      modules = [
        ./hardware-configuration.nix;
        ./config.nix
        ./secrets.nix
      ];
    }
    => ...
    ```

    # Type

    ```
    mkMachine :: AttrSet -> AttrSet
    ```

    # Arguments

    **args**
    : An attribute set containing `user`, `systemModule`, `modules, and `hostName` (optional).
      `hostName` is the hostname of the machine, defaulting to the name of the host module if
      unspecified. See the example above for an example of these values.
  */
  mkMachine =
    {
      user,
      modules,
      hostname,
      # FIXME: This is a workaround so that importing flakes can pass their flake-specific
      #        attributes.
      flake ? null
    }:
    lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          lib
          user
          hostname
          flake
          ;
      };
      modules = [
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.nixos-cli.nixosModules.nixos-cli
        outputs.nixosModules.nixsys
      ]
      ++ modules;
    };

  /**
    Create a home-manager user configuration of the given user name.

    # Example

    ```nix
    mkHome {
      user = "default";
      pkgs = nixpkgs.legacyPackages.x86-64_linux;
      extraModules = [ ];
    }
    => ...
    ```

    # Type

    ```
    mkHome :: AttrSet -> AttrSet
    ```

    # Arguments

    **args**
    : An attribute set containing `user` with a string value.
  */
  mkHome =
    {
      user,
      modules,
      pkgs,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs outputs;
        # FIXME: Find out how to avoid repeating this nixos module logic.
        user = {
          home-directory = "/home/${user.name}";
        }
        // user;
        asStandalone = true;
        lib = pkgs.lib.extend (
          _final: _prev: {
            inherit (inputs.home-manager.lib) hm;
            nixsys = { inherit home enabled enabledWith; };
          }
        );
      };
      modules = [
        inputs.sops-nix.homeManagerModules.sops
        outputs.homeManagerModules.nixsys
        ../modules/os/users/main/home-manager/home.nix
      ]
      ++ modules;
    };

  # nixos modules config-related library functions.
  os = import ./os.nix { inherit lib; };

  # home modules config-related library functions.
  home = import ./home.nix { inherit lib; };

  /**
    Shorthand for enabling a module option.

    # Example

    ```nix
    enabled
    => { enable = true; }
    ```

    # Type

    ```
    enabled :: AttrSet
    ```
  */
  enabled = {
    enable = true;
  };

  /**
    Enable a module option with the specified attributes.

    # Example

    ```nix
    enabledWith { foo = "bar"; baz = { x = 100; }; }
    => {
      enable = true;
      foo = "bar";
      baz = {
        x = 100;
      };
    }
    ```

    # Type

    ```
    enabledWith :: AttrSet -> AttrSet
    ```

    # Arguments

    **attrs**
    : The attribute set that will be used for the enabled module.
  */
  enabledWith = attrs: { enable = true; } // attrs;

  /**
    Shorthand for disabling a module option.

    # Example

    ```nix
    disabled
    => { enable = false; }
    ```

    # Type

    ```
    disabled :: AttrSet
    ```
  */
  disabled = {
    enable = false;
  };

  /**
    Return a list of absolute string paths to all default.nix files that are children of the given directory.

    # Example

    ```nix
    listDefaultNixFilesRecursive ./.
    => [
      ".../modules/os/default.nix"
      ".../modules/os/users/default.nix"
    ]
    ```

    # Type

    ```
    listDefaultNixFilesRecursive :: Path -> [String]
    ```

    # Arguments

    **dir**
    : The starting path from which the lookup starts.
  */
  # Credit: https://github.com/thursdaddy/nixos-config/blob/1ac56531349c75dc69eadee6f99e2a2006e1246e/modules/nixos/import.nix
  listDefaultNixFilesRecursive =
    let
      inherit (lib)
        collect
        concatStringsSep
        isString
        mapAttrsRecursive
        mapAttrs
        ;

      # Recursively collect all files from a starting dir.
      walkDir =
        dir:
        mapAttrs (file: type: if type == "directory" then walkDir "${dir}/${file}" else type) (
          builtins.readDir dir
        );

      # Create a list of file paths that are children of the given dir.
      listFilesRecursive =
        dir: collect isString (mapAttrsRecursive (path: _type: concatStringsSep "/" path) (walkDir dir));

      # Create a list of list paths with the given name that are children of the given dir.
      listFilesNamedRecursive =
        name: dir:
        builtins.map (file: dir + "/${file}") (
          builtins.filter (file: builtins.baseNameOf file == name) (listFilesRecursive dir)
        );
    in
    dir: listFilesNamedRecursive "default.nix" dir;
}

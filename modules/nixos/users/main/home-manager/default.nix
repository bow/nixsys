{
  config,
  lib,
  inputs,
  outputs,
  ...
}:
let
  inherit (lib) types;

  cfgMainUser = config.nixsys.users.main;
  cfg = cfgMainUser.home-manager;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.nixsys.users.main.home-manager = lib.mkOption {
    default = { };
    # Make this a freeform submodule so we can let home-manager modules define anything
    # from here on and not bother nixos modules about it.
    type = types.submodule {
      freeformType = types.attrsOf types.anything;
      options = {
        enable = lib.mkEnableOption "nixsys.users.main.home-manager";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    home-manager = {

      useGlobalPkgs = true;

      backupFileExtension = "hm-backup";

      extraSpecialArgs = {
        inherit inputs outputs;
        user = {
          inherit (cfgMainUser)
            name
            email
            full-name
            location
            timezone
            home-directory
            shell
            ;
        };
        asStandalone = false;
      };

      users.${cfgMainUser.name} = {
        imports = [
          outputs.homeManagerModules.nixsys
          ./home.nix
        ];

        # Everything in cfg that is not `enable` is meant for nixsys.home.
        nixsys.home = removeAttrs cfg [ "enable" ] // {
          # Façade for system-level config.
          system = {
            bluetooth.enable = config.nixsys.system.bluetooth.enable;
            docker.enable = config.nixsys.system.virtualization.host.docker.enable;
            libvirtd.enable = config.nixsys.system.virtualization.host.libvirtd.enable;
            pulseaudio.enable = config.nixsys.system.audio.pulseaudio.enable;
          };
        };
      };
    };
  };
}

{
  config,
  lib,
  inputs,
  outputs,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.os;

  btrfsEnabled = libcfg.isBTRFSEnabled config;

  cfgMainUser = config.nixsys.os.users.main;
  cfg = cfgMainUser.home-manager;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.nixsys.os.users.main.home-manager = lib.mkOption {
    default = { };
    # Make this a freeform submodule so we can let home-manager modules define anything
    # from here on and not bother nixos modules about it.
    type = types.submodule {
      freeformType = types.attrsOf types.anything;
      options = {
        enable = lib.mkEnableOption "nixsys.os.users.main.home-manager";
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
          os = {
            bluetooth.enable = config.nixsys.os.bluetooth.enable;
            btrfs.enable = btrfsEnabled;
            docker.enable = config.nixsys.os.virtualization.host.docker.enable;
            libvirtd.enable = config.nixsys.os.virtualization.host.libvirtd.enable;
            pulseaudio.enable = config.nixsys.os.audio.pulseaudio.enable;
          };
        };
      };
    };
  };
}

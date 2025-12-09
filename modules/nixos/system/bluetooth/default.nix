{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.nixos;

  desktopEnabled = libcfg.isDesktopEnabled config;

  cfg = config.nixsys.system.bluetooth;
in
{
  options.nixsys.system.bluetooth = {
    enable = lib.mkEnableOption "nixsys.system.bluetooth";
    power-on-boot = lib.mkOption {
      description = "Sets hardware.bluetooth.powerOnBoot";
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = cfg.power-on-boot;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
          FastConnectable = false;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };
    services.blueman.enable = lib.mkDefault desktopEnabled;
  };
}


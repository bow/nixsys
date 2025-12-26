{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.os;

  desktopEnabled = libcfg.isDesktopEnabled config;

  cfg = config.nixsys.os.bluetooth;
in
{
  options.nixsys.os.bluetooth = {
    enable = lib.mkEnableOption "nixsys.os.bluetooth";
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


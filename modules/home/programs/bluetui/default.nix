{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.home;

  bluetoothEnabled = libcfg.isBluetoothEnabled config;

  cfg = config.nixsys.home.programs.bluetui;
in
{
  options.nixsys.home.programs.bluetui = {
    enable = lib.mkEnableOption "nixsys.home.programs.bluetui" // {
      default = bluetoothEnabled;
    };
    add-desktop-entry = lib.mkOption {
      type = types.bool;
      default = true;
    };
    package = lib.mkPackageOption pkgs "bluetui" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.desktopEntries = lib.optionalAttrs cfg.add-desktop-entry {
      bluetui = {
        name = "BlueTUI";
        comment = "Open bluetui in a new $TERMINAL";
        exec = "${cfg.package}/bin/bluetui";
        terminal = true;
        categories = [
          "System"
          "ConsoleOnly"
        ];
      };
    };
  };
}

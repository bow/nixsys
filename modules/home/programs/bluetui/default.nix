{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.home;

  bluetoothEnabled = libcfg.isBluetoothEnabled config;

  cfg = config.nixsys.home.programs.bluetui;
in
{
  options.nixsys.home.programs.bluetui = {
    enable = lib.mkEnableOption "nixsys.home.programs.bluetui" // {
      default = bluetoothEnabled;
    };
    package = lib.mkPackageOption pkgs "bluetui" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}

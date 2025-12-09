{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.home;

  bluetoothEnabled = libcfg.isBluetoothEnabled config;

  cfg = config.nixsys.home.services.blueman-applet;
in
{
  options.nixsys.home.services.blueman-applet = {
    enable = lib.mkEnableOption "nixsys.home.services.blueman-applet" // {
      default = libcfg.isDesktopEnabled config;
    };
    package = lib.mkPackageOption pkgs "blueman" { };
  };

  config = lib.mkIf (cfg.enable && bluetoothEnabled) {
    services.blueman-applet = {
      inherit (cfg) package;
      enable = true;
    };
  };
}


{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.home;

  bluetoothEnabled = libcfg.isBluetoothEnabled config;

  cfg = config.nixsys.home.services.mpris-proxy;
in
{
  options.nixsys.home.services.mpris-proxy = {
    enable = lib.mkEnableOption "nixsys.home.services.mpris-proxy";
    package = lib.mkPackageOption pkgs "bluez" { };
  };

  config = lib.mkIf (cfg.enable && bluetoothEnabled) {
    services.mpris-proxy = {
      inherit (cfg) package;
      enable = true;
    };
  };
}

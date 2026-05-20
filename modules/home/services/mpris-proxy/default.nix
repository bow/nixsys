{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  bluetoothEnabled = osConfig.nixsys.os.bluetooth.enable or false;

  cfg = config.nixsys.home.services.mpris-proxy;
in
{
  options.nixsys.home.services.mpris-proxy = {
    enable = lib.mkEnableOption "nixsys.home.services.mpris-proxy" // {
      default = bluetoothEnabled;
    };
    package = lib.mkPackageOption pkgs "bluez" { };
  };

  config = lib.mkIf cfg.enable {
    services.mpris-proxy = {
      inherit (cfg) package;
      enable = true;
    };
  };
}

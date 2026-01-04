{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.home;

  bluetoothEnabled = libcfg.isBluetoothEnabled config;
  desktopEnabled = libcfg.isDesktopEnabled config;

  cfg = config.nixsys.home.services.blueman-applet;
in
{
  options.nixsys.home.services.blueman-applet = {
    enable = lib.mkEnableOption "nixsys.home.services.blueman-applet" // {
      default = bluetoothEnabled && desktopEnabled;
    };
    package = lib.mkPackageOption pkgs "blueman" { };
  };

  config = lib.mkIf cfg.enable {
    services.blueman-applet = {
      inherit (cfg) package;
      enable = true;
    };

    systemd.user.services.blueman-applet = {
      Install.WantedBy = lib.mkForce [ "default.target" ];
      Service = {
        Restart = "on-failure";
        RestartSec = 3;
      };
      Unit.After = lib.mkForce [ "display-manager.service" ];
    };
  };
}

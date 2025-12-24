{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.nixos;

  mainUserName = libcfg.getMainUserName config;
  homeCfg = libcfg.getHomeConfigOrNull config;

  cfg = config.nixsys.users.main.session.i3;
in
{
  options.nixsys.users.main.session.i3 = {
    enable = lib.mkEnableOption "nixsys.user.main.session.i3" // {
      default = config.nixsys.users.main.home-manager.desktop.i3.enable;
    };
  };

  config = lib.mkIf cfg.enable {

    services = {

      displayManager.defaultSession = "none+i3";

      xserver = {
        enable = true;
        autorun = false;
        displayManager.startx = {
          enable = true;
        };
        desktopManager = {
          xterm.enable = false;
        };
        windowManager.i3 = {
          enable = true;
        };
      };
    };

    programs = {
      dconf.enable = true;
      i3lock = {
        enable = true;
        package = pkgs.i3lock-color;
      };
    };

    security.pam.services.i3lock-color.enable = true;

    # FIXME: Think of a better way to expose the home-defined lock script.
    systemd =
      let
        templateName = "sleep";
      in
      lib.mkIf (homeCfg != null && homeCfg.desktop.i3.enable) {
        services."${templateName}@" = {
          enable = true;
          description = "i3 screen locker script";
          wantedBy = [ "sleep.target" ];
          before = [ "sleep.target" ];

          serviceConfig = {
            User = "%I";
            Type = "forking";
            Environment = [
              "DISPLAY=:0"
              "NOFORK=0"
            ];
            ExecStart = "-${homeCfg.desktop.i3.lock-script}";
          };
        };
        services."${templateName}@${mainUserName}" = {
          wantedBy = [ "sleep.target" ];
          before = [ "sleep.target" ];
          overrideStrategy = "asDropin";
        };
      };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.os;

  mainUserName = libcfg.getMainUserName config;
  homeCfg = libcfg.getHomeConfigOrNull config;

  polybarCfg = config.nixsys.os.users.main.session.polybar;
  cfg = config.nixsys.os.users.main.session.i3;
in
{
  options.nixsys.os.users.main.session.i3 = {
    enable = lib.mkEnableOption "nixsys.user.main.session.i3" // {
      default = config.nixsys.os.users.main.home-manager.desktop.i3.enable;
    };
    enable-autorandr-integration = lib.mkOption {
      type = types.bool;
      default = config.nixsys.os.display.autorandr.enable;
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

      autorandr.hooks.postswitch = lib.mkIf cfg.enable-autorandr-integration {
        "restart-i3" =
          # So that polybar is restarted after i3 is restarted.
          if polybarCfg.enable then
            "${homeCfg.desktop.i3.package}/bin/i3-msg restart && /run/current-system/systemd/bin/systemctl --user -M ${mainUserName}@ restart polybar"
          else
            "${homeCfg.desktop.i3.package}/bin/i3-msg restart";
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

    # Workaround for mouse left-click that sometimes stop working.
    environment.etc."systemd/system-sleep/vt-refresh.sh" =
      let
        desktopVT = config.services.greetd.settings.terminal.vt;
        nonDesktopVT = if desktopVT > 2 then desktopVT - 1 else desktopVT + 1;
      in
      {
        mode = "0555";
        text = ''
          #!/bin/sh
          STATE=/run/vt${toString desktopVT}-was-active

          case "$1" in
            pre)
              rm -f "$STATE"
              if [ "$(${pkgs.kbd}/bin/fgconsole)" = "7" ] && ${pkgs.procps}/bin/pgrep -x Xorg >/dev/null 2>&1; then
                touch "$STATE"
              fi
              ;;
            post)
              if [ -f "$STATE" ] && [ "$(${pkgs.kbd}/bin/fgconsole)" = "7" ]; then
                ${pkgs.kbd}/bin/chvt ${toString nonDesktopVT}
                sleep 0.3
                ${pkgs.kbd}/bin/chvt ${toString desktopVT}
              fi
              rm -f "$STATE"
              ;;
          esac
        '';
      };
  };
}

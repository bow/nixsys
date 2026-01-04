{
  config,
  lib,
  ...
}:
let
  libcfg = lib.nixsys.home;

  i3Enabled = libcfg.isI3Enabled config;

  cfg = config.nixsys.home.desktop.picom;
in
{
  options.nixsys.home.desktop.picom = {
    enable = lib.mkEnableOption "nixsys.home.desktop.picom" // {
      default = i3Enabled;
    };
  };

  config = lib.mkIf cfg.enable {

    services.picom = {
      enable = true;
      backend = "xrender";
      vSync = true;
      settings = {

        blur-kern = "3x3box";
        blur-background-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "_GTK_FRAME_EXTENTS@:c"
        ];

        fading = false;
        fade-in-step = 0.03;
        fade-out-step = 0.03;
        fade-delta = 0;

        focus-exclude = [
          "class_g = 'Cairo-clock'"
        ];

        active-opacity = 1.0;
        frame-opacity = 1.0;
        inactive-opacity = 1.0;
        inactive-opacity-override = false;
        opacity-rule = [
          "0:_NET_WM_STATE@:32a = '_NET_WM_STATE_HIDDEN'"
          "100:_NET_WM_STATE@:32a = '_NET_WM_STATE_FULLSCREEN'"
          "95:class_g  = 'Rofi'"
          "100:class_g = 'polybar'"
          "100:class_g = 'everdo'"
          "100:class_g = 'vlc'"
          "100:class_g = 'Spotify'"
          "100:class_g = 'Thunar'"
          "100:class_g = 'firefox'"
          "100:class_g = 'Google-chrome'"
          "100:class_g = 'Zathura'"
        ];

        shadow = true;
        shadow-exclude = [
          "name = 'Notification'"
          "class_g = 'Conky'"
          "class_g ?= 'Notify-osd'"
          "class_g = 'Cairo-clock'"
          "_GTK_FRAME_EXTENTS"
          "bounding_shaped"
          "class_g = 'firefox' && argb"
          "!I3_FLOATING_WINDOW && !class_g = 'Rofi' && !class_g = 'dmenu'"
        ];
        shadow-offset-x = -25;
        shadow-offset-y = -25;
        shadow-radius = 25;

        wintypes = {
          tooltip = {
            fade = true;
            shadow = true;
            opacity = 0.75;
            focus = true;
            full-shadow = false;
          };
          dock = {
            shadow = false;
          };
          dnd = {
            shadow = false;
          };
          popup_menu = {
            opacity = 0.9;
          };
          dropdown_menu = {
            opacity = 0.9;
          };
        };

        mark-wmwin-focused = true;
        mark-ovredir-focused = false;
        detect-rounded-corners = true;
        detect-client-opacity = true;
        refresh-rate = 0;
        detect-transient = true;
        detect-client-leader = true;
        use-damage = true;
        log-level = "warn";
      };
    };
  };
}

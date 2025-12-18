{
  config,
  pkgs,
  lib,
  user,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.home;

  ghosttyEnabled = libcfg.isGhosttyEnabled config;
  ghosttyPackage = libcfg.getGhosttyPackage config;

  theme =
    let
      mkWallpaperDrv =
        wallpaper:
        pkgs.stdenvNoCC.mkDerivation {
          pname = "${wallpaper.name}";
          version = "0.0.0";

          src = pkgs.fetchurl {
            inherit (wallpaper) sha256;
            name = "${wallpaper.name}-source";
            url = "${wallpaper.url}";
          };

          unpackPhase = "true";

          buildPhase = ''
            mkdir -p $out
            cp $src $out/original
            ${pkgs.imagemagick}/bin/magick $src -blur 0x8 $out/blurred
          '';
        };

      wallpaper = mkWallpaperDrv {
        inherit (cfg.wallpaper)
          name
          ext
          url
          sha256
          ;
      };
    in
    {
      desktop = {
        bg = "${wallpaper}/original";
        colors = {
          inherit (cfg.colors.desktop)
            bar-bg
            bar-fg
            focused-bg
            focused-child-border
            focused-fg
            focused-inactive-bg
            focused-inactive-fg
            placeholder-border
            placeholder-indicator
            unfocused-bg
            unfocused-border
            unfocused-fg
            urgent-bg
            urgent-fg
            ;
        };
      };
      lock-screen = {
        bg = "${wallpaper}/blurred";
        font = {
          name = "Titillium";
          package = pkgs.local.titillium-font;
        };
        colors = {
          inherit (cfg.colors.lock-screen)
            time
            greeter
            light
            dark
            ring
            ring-hl
            ring-bs
            ring-sep
            ;
        };
      };
    };

  lock-sh =
    with theme.lock-screen;
    pkgs.writeShellScript "lock.sh" ''
      FONT="${font.name}"
      COLOR_BG='${colors.dark}'
      COLOR_FG='${colors.light}'
      COLOR_RING='${colors.ring}'
      COLOR_RING_HL='${colors.ring-hl}'
      COLOR_RING_BS='${colors.ring-bs}'
      COLOR_RING_SEP='${colors.ring-sep}'
      COLOR_RING_VER="''${COLOR_RING_HL}"
      COLOR_RING_WRONG="''${COLOR_RING_BS}"

      NOFORK=''${NOFORK:-1}

      playing="''$([[ "''$(${pkgs.playerctl}/bin/playerctl status)" == "Playing" ]] && echo 1 || echo 0)"

      [[ "''${NOFORK}" -eq 1 ]] && [[ "''${playing}" -eq 1 ]] && ${pkgs.playerctl}/bin/playerctl play-pause

      ${pkgs.i3lock-color}/bin/i3lock \
          "''$( ([[ "''${NOFORK}" -eq 1 ]] && echo "\--nofork") || echo "" )" \
          -i "${theme.lock-screen.bg}" \
          --scale \
          --ignore-empty-password \
          --show-failed-attempts \
          --verif-text "" \
          --wrong-text "" \
          --noinput-text "" \
          --lock-text "locking" \
          --lockfailed-text "locking failed" \
          --radius 100 \
          --ring-color "''${COLOR_RING}" \
          --inside-color "''${COLOR_BG}" \
          --keyhl-color "''${COLOR_RING_HL}" \
          --bshl-color "''${COLOR_RING_BS}" \
          --line-color "''${COLOR_RING_SEP}" \
          --verif-color "''${COLOR_FG}" \
          --ringver-color "''${COLOR_RING_VER}" \
          --insidever-color "''${COLOR_BG}" \
          --verif-font "''${FONT}" \
          --wrong-color "''${COLOR_FG}" \
          --ringwrong-color "''${COLOR_RING_WRONG}" \
          --insidewrong-color "''${COLOR_BG}" \
          --wrong-font "''${FONT}" \
          --clock \
          --force-clock \
          --time-str "%H:%M" \
          --time-pos "ix:iy-240" \
          --time-color "''${COLOR_FG}" \
          --time-size 140 \
          --time-font "''${FONT}" \
          --date-str "%A, %d %B %Y" \
          --date-pos "tx:ty+50" \
          --date-color "''${COLOR_FG}" \
          --date-size 30 \
          --date-font "''${FONT}" \
          --greeter-text "${user.full-name} (${user.name}) · ''$(${pkgs.inetutils}/bin/hostname)" \
          --greeter-pos "15:h-15" \
          --greeter-align 1 \
          --greeter-color "''${COLOR_FG}" \
          --greeter-size 20 \
          --greeter-font "''${FONT}" \
          && ( ([[ "''${NOFORK}" -eq 1 ]] && [[ "''${playing}" -eq 1 ]] && ${pkgs.playerctl}/bin/playerctl play-pause) || true )
    '';

  rofiEnabled = libcfg.isRofiEnabled config;

  cfg = config.nixsys.home.desktop.i3;
in
{
  options.nixsys.home.desktop.i3 = {
    enable = lib.mkEnableOption "nixsys.home.desktop.i3";

    lock-script = lib.mkOption {
      description = "Screen lock script";
      type = types.package;
      default = lock-sh;
    };

    mod-key = lib.mkOption {
      description = "Mod key for i3";
      type = types.str;
      default = "Mod4";
    };

    package = lib.mkPackageOption pkgs "i3" { };

    wallpaper = lib.mkOption {
      default = {
        name = "francesco-ungaro-lcQzCo-X1vM-unsplash";
        ext = "jpg";
        url = "https://images.unsplash.com/photo-1729839472414-4f28edcb5b80?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb&dl=francesco-ungaro-lcQzCo-X1vM-unsplash.jpg&w=2400";
        sha256 = "sha256-t8W0N3yW/5n2GPsE6ngHCFHblOFNYs9kZKGyf92tJag=";
      };
      type = types.submodule {
        options = {
          name = lib.mkOption { type = types.str; };
          ext = lib.mkOption { type = types.str; };
          url = lib.mkOption { type = types.str; };
          sha256 = lib.mkOption { type = types.str; };
        };
      };
    };

    colors =
      let
        mkColorOption =
          default:
          lib.mkOption {
            inherit default;
            type = types.str;
          };
      in
      {
        desktop = {
          bar-bg = mkColorOption "#151515";
          bar-fg = mkColorOption "#bdbeab";
          focused-bg = mkColorOption "#184a53";
          focused-child-border = mkColorOption "";
          focused-fg = mkColorOption "#ffffff";
          focused-inactive-bg = mkColorOption "#3c3836";
          focused-inactive-fg = mkColorOption "#a89984";
          placeholder-border = mkColorOption "#000000";
          placeholder-indicator = mkColorOption "#000000";
          unfocused-bg = mkColorOption "#282828";
          unfocused-border = mkColorOption "#222222";
          unfocused-fg = mkColorOption "#665c54";
          urgent-bg = mkColorOption "#e3ac2d";
          urgent-fg = mkColorOption "#151515";
        };
        lock-screen = rec {
          time = mkColorOption light;
          greeter = mkColorOption dark;

          light = mkColorOption "#ffffffff";
          dark = mkColorOption "#1d2021ee";
          ring = mkColorOption "#007c5bff";
          ring-hl = mkColorOption "#e3ac2dff";
          ring-bs = mkColorOption "#d1472fff";
          ring-sep = mkColorOption "#00000000";
        };
      };
  };

  config = lib.mkIf cfg.enable {
    xsession.windowManager.i3 = {
      enable = true;

      inherit (cfg) package;
      config = rec {
        bars = [ ];
        modifier = cfg.mod-key;
        colors =
          let
            colors = cfg.colors.desktop;
          in
          {
            focused = {
              border = colors.focused-bg;
              background = colors.focused-bg;
              text = colors.focused-fg;
              indicator = colors.focused-inactive-bg;
              childBorder = colors.focused-child-border;
            };
            focusedInactive = {
              border = colors.focused-inactive-bg;
              background = colors.focused-inactive-bg;
              text = colors.focused-inactive-fg;
              indicator = colors.focused-bg;
              childBorder = colors.focused-inactive-bg;
            };
            unfocused = {
              border = colors.unfocused-border;
              background = colors.unfocused-bg;
              text = colors.unfocused-fg;
              indicator = colors.unfocused-bg;
              childBorder = colors.unfocused-bg;
            };
            urgent = {
              border = colors.urgent-bg;
              background = colors.urgent-bg;
              text = colors.urgent-fg;
              indicator = colors.urgent-bg;
              childBorder = colors.urgent-bg;
            };
            placeholder = {
              border = colors.placeholder-border;
              background = colors.focused-inactive-bg;
              text = colors.focused-inactive-fg;
              indicator = colors.placeholder-indicator;
              childBorder = colors.focused-inactive-bg;
            };
          };
        fonts = {
          names = [ "DroidSansMono Nerd Font" ];
          size = "8";
        };
        floating = { inherit modifier; };
        gaps = {
          inner = 2;
          outer = 23;
          bottom = 22;
          top = 0;
        };
        modes = {
          resize = {
            "h" = "resize shrink width 10 px or 10 ppt";
            "j" = "resize grow height 10 px or 10 ppt";
            "k" = "resize shrink height 10 px or 10 ppt";
            "l" = "resize grow width 10 px or 10 ppt";

            "Right" = "resize shrink width 10 px or 10 ppt";
            "Up" = "resize grow height 10 px or 10 ppt";
            "Down" = "resize shrink height 10 px or 10 ppt";
            "Left" = "resize grow width 10 px or 10 ppt";

            "Return" = ''mode "default"'';
            "Escape" = ''mode "default"'';
          };
        };
        window = {
          hideEdgeBorders = "smart";
          commands =
            builtins.map
              (class: {
                criteria = { inherit class; };
                command = "border pixel 0";
              })
              [
                "ghostty"
                "Zathura"
                "firefox"
                "google-chrome"
              ];
        };
        defaultWorkspace = keybindings."${modifier}+2";
        keybindings = {
          # Navigation.
          "${modifier}+j" = "focus left";
          "${modifier}+k" = "focus down";
          "${modifier}+l" = "focus up";
          "${modifier}+semicolon" = "focus right";
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          # Move windows.
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          # Split windows.
          "${modifier}+h" = "split h";
          "${modifier}+v" = "split v";

          # Enter fullscreen mode for the focused container.
          "${modifier}+f" = "fullscreen toggle";

          # Change container layout (stacked, tabbed, toggle split).
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";

          # Toggle tiling / floating.
          "${modifier}+Shift+space" = "floating toggle";

          # Change focus between tiling / floating windows.
          "${modifier}+space" = "focus mode_toggle";

          # Focus the parent container.
          "${modifier}+a" = "focus parent";

          # Switch to workspace.
          # FIXME: How to sync with polybar workspaces?
          "${modifier}+1" = "workspace 1:";
          "${modifier}+2" = "workspace 2:";
          "${modifier}+3" = "workspace 3:";
          "${modifier}+4" = "workspace 4:";
          "${modifier}+5" = "workspace 5:";
          "${modifier}+6" = "workspace 6:•";
          "${modifier}+7" = "workspace 7:•";
          "${modifier}+8" = "workspace 8:•";
          "${modifier}+9" = "workspace 9:•";
          "${modifier}+0" = "workspace 10:•";
          "${modifier}+p" = "workspace 11:";
          "${modifier}+c" = "workspace 12:";
          "${modifier}+b" = "workspace 13:";

          # Move focused container to workspace.
          "${modifier}+Shift+1" = "move container to workspace 1:";
          "${modifier}+Shift+2" = "move container to workspace 2:";
          "${modifier}+Shift+3" = "move container to workspace 3:";
          "${modifier}+Shift+4" = "move container to workspace 4:";
          "${modifier}+Shift+5" = "move container to workspace 5:";
          "${modifier}+Shift+6" = "move container to workspace 6:•";
          "${modifier}+Shift+7" = "move container to workspace 7:•";
          "${modifier}+Shift+8" = "move container to workspace 8:•";
          "${modifier}+Shift+9" = "move container to workspace 9:•";
          "${modifier}+Shift+0" = "move container to workspace 10:•";
          "${modifier}+Shift+p" = "move container to workspace 11:";
          "${modifier}+Shift+c" = "move container to workspace 12:";
          "${modifier}+Shift+b" = "move container to workspace 13:";

          # Move between workspaces.
          "${modifier}+Prior" = "workspace prev";
          "${modifier}+Next" = "workspace next";
          "${modifier}+Shift+n" = "move workspace to output next";
          "${modifier}+n" = "focus output next";

          # Reload the configuration file.
          "${modifier}+Shift+o" = "reload";

          # Restart i3 inplace (preserves layout/session, can be used to upgrade i3)
          "${modifier}+Shift+r" = "restart";

          # Exit i3 (logs out of an X session).
          "${modifier}+Shift+e" = ''
            exec "${cfg.package}/bin/i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' '${cfg.package}/bin/i3-msg exit'"
          '';

          # Shortcuts.
          "${modifier}+Shift+q" = "kill";
          "${modifier}+r" = ''mode "resize"'';

          # Interact with applications.
          "${modifier}+backslash" = "exec ${pkgs.xfce.thunar}/bin/thunar";

          # Audio + video controls.
          "XF86AudioRaiseVolume" =
            "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" =
            "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" =
            "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec --no-startup-id ${pkgs.alsa-utils}/bin/amixer set Capture toggle";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s +5%";
          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%-";

          # System controls.
          "${modifier}+Shift+z" = "exec ${pkgs.systemd}/bin/systemctl suspend";
          "${modifier}+Shift+x" = "exec ${lock-sh}";
        }
        // lib.optionalAttrs ghosttyEnabled {
          "${modifier}+Return" = "exec ${ghosttyPackage}/bin/ghostty";
        }
        // lib.optionalAttrs rofiEnabled {
          "${modifier}+Tab" = "exec ${pkgs.rofi}/bin/rofi -show combi";
        };
        startup = [
          {
            command = "${pkgs.systemd}/bin/systemctl --user restart polybar";
            notification = false;
            always = true;
          }
          {
            command = "${pkgs.networkmanagerapplet}/bin/nm-applet";
            notification = false;
            always = true;
          }
          {
            command = "${pkgs.feh}/bin/feh --bg-scale ${theme.desktop.bg}";
            notification = false;
            always = true;
          }
          {
            command = "${pkgs.systemd}/bin/systemctl --user start picom";
            notification = false;
            always = true;
          }
        ];
      };
    };

    home.file = {
      ".xinitrc" = {
        text = "exec i3";
      };
      ".Xdefaults" = {
        text = ''
          *color0: #111111
          *color1: #803232
          *color2: #3d762f
          *color3: #aa9943
          *color4: #27528e
          *color5: #706c9a
          *color6: #5da5a5
          *color7: #d0d0d0
          *color8: #111111
          *color9: #c43232
          *color10: #5ab23a
          *color11: #efef60
          *color12: #4388e1
          *color13: #a07de7
          *color14: #98e1e1
          *color15: #ffffff

          xterm*faceSize: 11
          xterm*boldFont: fixed
          xterm*font: fixed

          xterm*foreground: rgb:ff/ff/ff
          xterm*background: rgb:11/11/11
          xterm*color0: rgb:11/11/11
          xterm*color1: rgb:80/32/32
          xterm*color2: rgb:3d/76/2f
          xterm*color3: rgb:aa/99/43
          xterm*color4: rgb:27/52/8e
          xterm*color5: rgb:70/6c/9a
          xterm*color6: rgb:5d/a5/a5
          xterm*color7: rgb:d0/d0/d0
          xterm*color8: rgb:11/11/11
          xterm*color9: rgb:c43/23/2
          xterm*color10: rgb:5a/b2/3a
          xterm*color11: rgb:ef/ef/60
          xterm*color12: rgb:43/88/e1
          xterm*color13: rgb:a0/7d/e7
          xterm*color14: rgb:98/e1/e1
          xterm*color15: rgb:ff/ff/ff

          xterm*boldMode: false
        '';
      };
    };
  };
}

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
  pulseaudioEnabled = libcfg.isPulseaudioEnabled config;
  pipewireEnabled = libcfg.isPipewireEnabled config;

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
          --fill \
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
          greeter = mkColorOption light;

          light = mkColorOption "#ffffffff";
          dark = mkColorOption "#1d2021ee";
          ring = mkColorOption "#007c5bff";
          ring-hl = mkColorOption "#e3ac2dff";
          ring-bs = mkColorOption "#d1472fff";
          ring-sep = mkColorOption "#00000000";
        };
      };

    extra-keybindings = lib.mkOption {
      type = types.attrs;
      default = { };
    };

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
      type = types.submodule {
        options = {
          name = lib.mkOption { type = types.str; };
          ext = lib.mkOption { type = types.str; };
          url = lib.mkOption { type = types.str; };
          sha256 = lib.mkOption { type = types.str; };
        };
      };
      default = {
        name = "adrien-olichon-RCAhiGJsUUE-unsplash";
        ext = "jpg";
        url = "https://images.unsplash.com/photo-1533134486753-c833f0ed4866?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
        sha256 = "sha256-BbAWNMOggHet7muY+pdsiXR2RKPUOOAX3o/v83sgh/k=";
      };
    };

    workspaces = lib.mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            key = lib.mkOption { type = types.str; };
            symbol = lib.mkOption { type = types.str; };
          };
        }
      );
      apply = workspaces: lib.imap1 (index: value: { inherit index; } // value) workspaces;
      default = [
        {
          key = "1";
          symbol = "";
        }
        {
          key = "2";
          symbol = "";
        }
        {
          key = "3";
          symbol = "";
        }
        {
          key = "4";
          symbol = "";
        }
        {
          key = "5";
          symbol = "";
        }
        {
          key = "6";
          symbol = "•";
        }
        {
          key = "7";
          symbol = "•";
        }
        {
          key = "8";
          symbol = "•";
        }
        {
          key = "9";
          symbol = "•";
        }
        {
          key = "0";
          symbol = "•";
        }
        {
          key = "p";
          symbol = "";
        }
        {
          key = "c";
          symbol = "";
        }
        {
          key = "b";
          symbol = "";
        }
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    xsession.windowManager.i3 = {
      enable = true;

      inherit (cfg) package;
      extraConfig = ''
        set $mod ${cfg.mod-key}
      '';
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
        defaultWorkspace = keybindings."$mod+2";
        keybindings =
          let
            mkWorkspaceBindings =
              workspaces:
              let
                bindings =
                  # [ { index = ...; key = "..."; symbol = "..."; } ]
                  # => [ { "$mod+${key}" = "workspace ${index}:${symbol}"; ... } ]
                  builtins.map (
                    ws:
                    let
                      wsID = "${builtins.toString ws.index}:${ws.symbol}";
                    in
                    {
                      "$mod+${ws.key}" = "workspace ${wsID}";
                      "$mod+Shift+${ws.key}" = "move container to workspace ${wsID}";
                    }
                  ) workspaces;
              in
              builtins.foldl' (acc: item: acc // item) { } bindings;
          in
          {
            # Navigation.
            "$mod+j" = "focus left";
            "$mod+k" = "focus down";
            "$mod+l" = "focus up";
            "$mod+semicolon" = "focus right";
            "$mod+Left" = "focus left";
            "$mod+Down" = "focus down";
            "$mod+Up" = "focus up";
            "$mod+Right" = "focus right";

            # Move windows.
            "$mod+Shift+h" = "move left";
            "$mod+Shift+j" = "move down";
            "$mod+Shift+k" = "move up";
            "$mod+Shift+l" = "move right";
            "$mod+Shift+Left" = "move left";
            "$mod+Shift+Down" = "move down";
            "$mod+Shift+Up" = "move up";
            "$mod+Shift+Right" = "move right";

            # Split windows.
            "$mod+h" = "split h";
            "$mod+v" = "split v";

            # Enter fullscreen mode for the focused container.
            "$mod+f" = "fullscreen toggle";

            # Change container layout (stacked, tabbed, toggle split).
            "$mod+s" = "layout stacking";
            "$mod+w" = "layout tabbed";
            "$mod+e" = "layout toggle split";

            # Toggle tiling / floating.
            "$mod+Shift+space" = "floating toggle";

            # Change focus between tiling / floating windows.
            "$mod+space" = "focus mode_toggle";

            # Focus the parent container.
            "$mod+a" = "focus parent";

            # Move between workspaces.
            "$mod+Prior" = "workspace prev";
            "$mod+Next" = "workspace next";
            "$mod+Shift+n" = "move workspace to output next";
            "$mod+n" = "focus output next";

            # Reload the configuration file.
            "$mod+Shift+o" = "reload";

            # Restart i3 inplace (preserves layout/session, can be used to upgrade i3)
            "$mod+Shift+r" = "restart";

            # Exit i3 (logs out of an X session).
            "$mod+Shift+e" = ''
              exec "${cfg.package}/bin/i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' '${cfg.package}/bin/i3-msg exit'"
            '';

            # Shortcuts.
            "$mod+Shift+q" = "kill";
            "$mod+r" = ''mode "resize"'';

            # Interact with applications.
            # Can not refer to the Nix store package here because thunar is installed system-wide, with
            # some modifications.
            "$mod+backslash" = "exec thunar";

            # Video controls.
            "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s +5%";
            "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%-";

            # System controls.
            "$mod+Shift+z" = "exec /run/current-system/systemd/bin/systemctl suspend";
            "$mod+Shift+x" = "exec ${lock-sh}";
          }
          // lib.optionalAttrs pulseaudioEnabled {
            "XF86AudioRaiseVolume" =
              "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86AudioLowerVolume" =
              "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioMute" =
              "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86AudioMicMute" = "exec --no-startup-id ${pkgs.alsa-utils}/bin/amixer set Capture toggle";
          }
          // lib.optionalAttrs pipewireEnabled {
            "XF86AudioRaiseVolume" =
              "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.2 @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" =
              "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86AudioMute" =
              "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioMicMute" =
              "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          }
          // mkWorkspaceBindings cfg.workspaces
          // lib.optionalAttrs ghosttyEnabled {
            "$mod+Return" = "exec ${ghosttyPackage}/bin/ghostty";
          }
          // lib.optionalAttrs rofiEnabled {
            "$mod+Tab" = "exec ${pkgs.rofi}/bin/rofi -show combi";
          }
          // cfg.extra-keybindings;
        startup = [
          {
            command = "${pkgs.feh}/bin/feh --bg-fill ${theme.desktop.bg}";
            notification = false;
            always = true;
          }
        ];
      };
    };

    home.file = {
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

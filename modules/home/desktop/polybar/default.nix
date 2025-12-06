{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.home;

  polybar-module-load-avg-sh = pkgs.writeShellScript "polybar-module-load-avg.sh" ''
    ${pkgs.gawk}/bin/awk '{printf("%{F#665c54} %{F#e8e8d3}%2.1f · %2.1f", $1, $2)}' < /proc/loadavg
  '';

  polybar-module-power-sh = pkgs.writeShellScript "polybar-module-power.sh" ''
    SCRIPT_PATH="''$(readlink -f "''$0")"

    # Returns 1 if AC power is connected, 0 otherwise.
    get_ac_status() {
        ac_id=''$(${pkgs.upower}/bin/upower -e | ${pkgs.gnugrep}/bin/grep line_power_AC)
        if ${pkgs.upower}/bin/upower -i "''${ac_id}" | ${pkgs.gnugrep}/bin/grep -Eq 'online:\s+yes'; then
            ${pkgs.coreutils}/bin/echo 1
        else
            ${pkgs.coreutils}/bin/echo 0
        fi
    }

    # Returns the charge percentage from all batteries combined.
    calc_battery_percent() {
        total_energy=0
        total_full=0

        for bat in ''$(${pkgs.upower}/bin/upower -e | ${pkgs.gnugrep}/bin/grep battery_BAT); do
            cur=''$(${pkgs.upower}/bin/upower -i "''$bat" | ${pkgs.gawk}/bin/awk '/energy:/{print ''$2}')
            full=''$(${pkgs.upower}/bin/upower -i "''$bat" | ${pkgs.gawk}/bin/awk '/energy-full:/{print ''$2}')
            total_energy=''$(${pkgs.coreutils}/bin/echo "''$total_energy + ''$cur" | ${pkgs.bc}/bin/bc)
            total_full=''$(${pkgs.coreutils}/bin/echo "''$total_full + ''$full" | ${pkgs.bc}/bin/bc)
        done

        total_full_int="''$(printf "%.0f" "''$total_full")"

        if [ "''$total_full_int" -gt 0 ]; then
            ${pkgs.coreutils}/bin/echo "''$total_energy / ''$total_full" | ${pkgs.bc}/bin/bc -l | ${pkgs.gawk}/bin/awk '{printf("%.0f\n", ''$1 * 100)}'
        fi
    }

    # Prints the power status for display in polybar.
    print_power_status() {
        battery_percent=''$(calc_battery_percent)

        # System does not have battery.
        if [ -z "''$battery_percent" ]; then
            icon=""
            ${pkgs.coreutils}/bin/echo "%{F#504945}''$icon"

        # System has battery and it is plugged in.
        elif [ "''$(get_ac_status)" -eq 1 ]; then

            # Battery is (close to) full.
            if [ "''$battery_percent" -ge 99 ] || [ -z "''$battery_percent" ] ; then
                icon=""
                ${pkgs.coreutils}/bin/echo "%{F#504945}''$icon"

            # Battery is charging.
            else
                icon=""
                ${pkgs.coreutils}/bin/echo "%{F#504945}''$icon %{F#e8e8d3}''$battery_percent%"
            fi

        # System has battery and it is not plugged in.
        elif [ "''$battery_percent" -ge 0 ]; then
            if [ "''$battery_percent" -ge 85 ]; then
                icon=" "
            elif [ "''$battery_percent" -ge 60 ]; then
                icon=" "
            elif [ "''$battery_percent" -ge 40 ]; then
                icon=" "
            elif [ "''$battery_percent" -ge 15 ]; then
                icon=" "
            else
                icon=" "
            fi

            ${pkgs.coreutils}/bin/echo "%{F#504945}''$icon %{F#e8e8d3}''$battery_percent%"

        # Error state.
        else
            icon=""
            ${pkgs.coreutils}/bin/echo "%{F#bd2c40}''$icon"
        fi
    }

      case "''$1" in
          --update)
              pid=''$(pgrep -xf "/bin/sh ''${SCRIPT_PATH}")

              if [ "''$pid" != "" ]; then
                  ${pkgs.coreutils}/bin/kill -10 "''$pid"
              fi
              ;;
          *)
              trap exit INT
              trap "${pkgs.coreutils}/bin/echo" USR1

              while true; do
                  print_power_status

                  ${pkgs.coreutils}/bin/sleep 30 &
                  wait
              done
              ;;
      esac
  '';

  i3Enabled = libcfg.isI3Enabled config;

  cfg = config.nixsys.home.desktop.polybar;
in
{
  options.nixsys.home.desktop.polybar = {
    enable = lib.mkEnableOption "nixsys.home.desktop.polybar" // {
      default = i3Enabled;
    };
    package = lib.mkPackageOption pkgs.unstable "polybar" { };
  };

  config = lib.mkIf cfg.enable {

    services.polybar = {
      enable = true;

      package = cfg.package.override {
        alsaSupport = true;
        githubSupport = true;
        iwSupport = true;
        i3Support = i3Enabled;
        mpdSupport = true;
        nlSupport = true;
        pulseSupport = true;
      };

      settings = {

        "global/wm" = {
          margin = {
            top = 0;
            bottom = 0;
          };
        };

        "colors" = {
          background = {
            text = "#151515";
            alt = "#333";
          };
          foreground = {
            text = "#e8e8d3";
            alt = "#504945";
          };
          primary = "#007c5b";
          secondary = "#e3ac2d";
          alert = "#bd2c40";
        };

        "bar/top" = {
          monitor = ''''${env:POLYBAR_MONITOR}'';
          width = "100%";
          height = 33;
          radius = 0;
          fixed.center = true;
          background = ''''${colors.background}'';
          foreground = ''''${colors.foreground}'';

          line = {
            size = 2;
            color = "#f00";
          };

          border = {
            size = 0;
            bottom.size = 0;
          };

          padding = {
            left = 1;
            right = 1;
          };

          module.margin = 2;

          font = [
            "Titillium:pixelsize=12;2"
            "FontAwesome:style=Regular:pixelsize=12;2"
            "Font Awesome 7 Free Solid:style=Solid,Regular:pixelsize=12;2"
            "icomoon:style=Regular:pixelsize=12;2"
            "octicons:style=Medium:pixelsize=12;2"
            "Siji:style=Regular:pixelsize=12;2"
            "Noto Color Emoji:scale=15:antialias=false;0"
          ];

          modules = {
            left = lib.optionalString i3Enabled "i3";
            center = "date";
            right = lib.concatStringsSep " " [
              "cpu"
              "memory"
              "loadavg"
              "wlan"
              "eth"
              "pulseaudio"
              "temperature"
              "battery-combined"
              "tray"
            ];
          };
        };

        "module/battery-combined" = {
          type = "custom/script";
          exec = "${polybar-module-power-sh}";
          tail = true;
        };

        "module/loadavg" = {
          type = "custom/script";
          exec = "${polybar-module-load-avg-sh}";
          interval = 1;
        };

        "module/filesystem" = {
          type = "internal/fs";
          interval = 25;
          mount = [
            "/"
            "/var"
            "/tmp"
          ];
          label = {
            mounted = "%{F#0a81f5}%mountpoint%%{F-}: %percentage_used%%";
            unmounted = {
              text = "%mountpoint% not mounted";
              foreground = ''''${colors.foreground-alt}'';
            };
          };
        };

        "module/cpu" = {
          type = "internal/cpu";
          interval = 1;
          label = "%percentage%%";
          format = {
            text = "<label>";
            prefix = {
              text = " ";
              foreground = ''''${colors.foreground-alt}'';
            };
          };
          bar = {
            load = {
              width = 5;
              empty = "━";
              fill = "━";
              indicator = "┃";
            };
          };
          ramp = {
            coreload = [
              "▁"
              "▂"
              "▄"
              "▆"
              "█"
            ];
          };
        };

        "module/memory" = {
          type = "internal/memory";
          interval = 1;
          warn.percentage = 80;
          label = {
            text = "%percentage_used%% · %gb_used%";
            warn = "%percentage_used%% · %gb_used%";
          };
          format = {
            text = "<label>";
            prefix = {
              text = " ";
              foreground = ''''${colors.foreground-alt}'';
            };
            warn = {
              text = "<label-warn>";
              prefix = {
                text = " ";
                foreground = ''''${colors.alert}'';
              };
            };
          };
        };

        "module/wlan" = {
          type = "internal/network";
          interface = {
            text = ''''${env:POLYBAR_WIRELESS_IF}'';
            type = "wireless";
          };
          interval = 3;

          format = {
            connected = "%{A:nm-connection-editor&:}<ramp-signal> <label-connected>%{A}";
            disconnected = "%{A:nm-connection-editor&:}<label-disconnected>%{A}";
          };

          label = {
            connected = "%signal%% · %essid%";
            disconnected = {
              text = " ";
              foreground = ''''${colors.foreground-alt}'';
            };
          };

          ramp = {
            signal = {
              text = [ " " ];
              foreground = ''''${colors.foreground-alt}'';
            };
          };
        };

        "module/eth" = {
          type = "internal/network";
          interface = ''''${env:POLYBAR_ETH_IF}'';
          interval = 3;
          format = {
            disconnected.prefix = {
              text = "";
              foreground = ''''${colors.foreground-alt}'';
            };
            connected.prefix = {
              text = "";
              foreground = ''''${colors.foreground-alt}'';
            };
          };
          label = {
            disconnected = "";
            connected = "%linkspeed%";
          };
        };

        "module/date" = {
          type = "internal/date";
          interval = 1;
          format.prefix = {
            text = "  ";
            foreground = ''''${colors.foreground-alt}'';
          };
          label = "%date%%time%";
          date = {
            text = "%a, %e %b %y - ";
            alt = "%FT";
          };
          time = {
            text = "%H:%M";
            alt = "%T%z / W%V";
          };
        };

        "module/pulseaudio" = {
          type = "internal/pulseaudio";

          format = {
            volume = "<ramp-volume> <label-volume>";
            muted = {
              prefix = " ";
              foreground = ''''${colors.foreground-alt}'';
            };
          };

          label = {
            volume = "%percentage%%";
            muted = " -";
          };

          ramp.volume = {
            foreground = ''''${colors.foreground-alt}'';
            text = [
              ""
              ""
              ""
            ];
          };
        };

        "module/temperature" = {
          type = "internal/temperature";
          thermal.zone = 0;
          warn.temperature = 60;

          format = {
            text = "<ramp> <label>";
            warn = "<ramp> <label-warn>";
          };

          label = {
            text = "%temperature-c%";
            warn = {
              text = "%temperature-c%";
              foreground = ''''${colors.secondary}'';
            };
          };

          ramp = {
            text = [
              ""
              ""
              ""
              ""
              ""
            ];
            foreground = ''''${colors.foreground-alt}'';
          };
        };

        "module/tray" = {
          type = "internal/tray";
          tray-padding = 2;
          tray-size = "50%";
        };

        "settings" = {
          screenchange.reload = true;
        };
      };

      settings."module/i3" = lib.mkIf i3Enabled {
        type = "internal/i3";
        format = "<label-mode> <label-state> <label-mode>";
        strip.wsnumbers = true;
        index.sort = true;
        wrapping.scroll = false;

        # FIXME: How to sync with i3 workspaces?
        ws.icon = [
          "1;"
          "2;"
          "3;"
          "4;"
          "5;"
          "6;•"
          "7;•"
          "8;•"
          "9;•"
          "10;•"
          "11;"
          "12;"
          "13;"
        ];

        label = {
          mode = {
            padding = 2;
            foreground = "#000";
            background = ''''${colors.primary}'';
          };
          # focused: active workspace on focused monitor.
          focused = {
            text = "%name%";
            padding = 6;
            foreground = ''''${colors.foreground}'';
            underline = ''''${colors.foreground}'';
          };
          # unfocused: inactive workspace on any monitor.
          unfocused = {
            text = ''''${self.label-focused}'';
            foreground = ''''${colors.foreground-alt}'';
            padding = ''''${self.label-focused-padding}'';
          };
          # visible = active workspace on unfocused monitor.
          visible = {
            text = ''''${self.label-focused}'';
            padding = ''''${self.label-focused-padding}'';
            foreground = ''''${colors.foreground-alt}'';
            underline = ''''${colors.foreground-alt}'';
          };
          # urgent = workspace with urgency hint set.
          urgent = {
            text = ''''${self.label-focused}'';
            padding = ''''${self.label-focused-padding}'';
            foreground = ''''${colors.secondary}'';
            underline = ''''${colors.secondary}'';
          };
        };
      };

      script = ''
        #!/usr/bin/env sh

        # Terminate already running bar instances
        ${pkgs.coreutils}/bin/pkill polybar

        # Wait until the processes have been shut down
        while ${pkgs.procps}/bin/pgrep -x polybar >/dev/null; do sleep 1; done

        # Get network interface names that might be shown
        wireless_if="''$(${pkgs.iproute2}/bin/ip -o link show | ${pkgs.gnugrep}/bin/grep ' state UP ' | ${pkgs.gawk}/bin/awk -F: '/wl|wlan/ {print $2}' | ${pkgs.coreutils}/bin/tr -d ' ')"
        eth_if="''$(${pkgs.iproute2}/bin/ip -o link show | ${pkgs.gnugrep}/bin/grep ' state UP ' | ${pkgs.gawk}/bin/awk -F: '/^( *[0-9]+: (en|eth))/ {print $2}' | ${pkgs.coreutils}/bin/tr -d ' ' | ${pkgs.coreutils}/bin/head -n1)"

        # Launch polybar in all connected monitors
        for mon in ''$(${pkgs.xorg.xrandr}/bin/xrandr | ${pkgs.gnugrep}/bin/grep " connected " | ${pkgs.gawk}/bin/awk '{ print $1 }' | ${pkgs.coreutils}/bin/sort -r); do
            POLYBAR_MONITOR="''${mon}" POLYBAR_WIRELESS_IF="''${wireless_if}" POLYBAR_ETH_IF="''${eth_if}" polybar top &
        done
      '';
    };

    systemd.user.services.polybar = {
      # FIXME: This should be systemctl --user import-environment DISPLAY XAUTHORITY somewhere.
      Service.Environment = [ "DISPLAY=:0" ];
      # NOTE: upower dependency is explicit in battery script.
      Unit.After = [ "upower.service" ];
    };
  };
}

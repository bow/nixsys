{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.nixsys) enabled;
  libcfg = lib.nixsys.home;

  desktopEnabled = libcfg.isDesktopEnabled config;
  pulseaudioEnabled = libcfg.isPulseaudioEnabled config;

  cfg = config.nixsys.home.profile.personal;
in
{
  options.nixsys.home.profile.personal = {
    enable = lib.mkEnableOption "nixsys.home.profile.personal";
  };
  config = lib.mkIf cfg.enable {

    nixsys.home.desktop = {
      fonts = enabled;
      xdg = enabled;
    };

    home.packages = [
      pkgs.unstable.nh
    ]
    ++ lib.optionals desktopEnabled [
      # File storage.
      pkgs.dropbox

      # PDF reader.
      pkgs.evince

      # Web browser.
      pkgs.firefox

      # Web browser.
      pkgs.google-chrome

      # Text editor.
      pkgs.geany

      # Disk partition editor.
      pkgs.gparted

      # Screnshot tool.
      pkgs.maim

      # Image viewer.
      pkgs.nomacs

      # Markdown-based knowledge base.
      pkgs.obsidian

      # VPN client.
      pkgs.openconnect

      # Mail client.
      pkgs.protonmail-bridge

      # Music player.
      pkgs.spotify

      # Image viewer.
      pkgs.sxiv

      # Logitech peripherals.
      pkgs.solaar

      # Synology.
      pkgs.synology-drive-client

      # Email client.
      pkgs.thunderbird-latest

      # Official Todoist app.
      pkgs.todoist-electron

      # Encryption tooling.
      pkgs.veracrypt

      # Video player.
      pkgs.vlc

      # File explorer + plugins.
      pkgs.xfce.thunar
      pkgs.xfce.thunar-archive-plugin
      pkgs.xfce.thunar-dropbox-plugin
      pkgs.xfce.thunar-volman
    ];

    nixsys.home = {

      profile = {
        base = enabled;
        devel = enabled;
      };

      programs = {
        # Audio.
        ncmpcpp = enabled;

        # Backup.
        restic = enabled;

        # Chat.
        weechat = enabled;

        # Media tools.
        pdftk = enabled;
        imagemagick = enabled;

        # Network clients.
        aria2 = enabled;
        elinks = enabled;
        wget = enabled;

        # Security.
        gpg = enabled;
        pass = enabled;
        sequoia-sq = enabled;
      }
      // lib.optionalAttrs desktopEnabled {
        zathura = enabled;
      }
      // lib.optionalAttrs (desktopEnabled && pulseaudioEnabled) {
        pavucontrol = enabled;
      };

      services = {
        mpd = enabled;
        mpris-proxy = enabled;
        redshift = enabled;
      };
    };
  };
}

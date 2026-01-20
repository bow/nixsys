{
  config,
  lib,
  ...
}:
let
  inherit (lib.nixsys) enabled;
  libcfg = lib.nixsys.home;

  audioEnabled = libcfg.isAudioEnabled config;
  btrfsEnabled = libcfg.isBTRFSEnabled config;
  desktopEnabled = libcfg.isDesktopEnabled config;
  pipewireEnabled = libcfg.isPipewireEnabled config;
  pulseaudioEnabled = libcfg.isPulseaudioEnabled config;

  cfg = config.nixsys.home.profile.work;
in
{
  options.nixsys.home.profile.work = {
    enable = lib.mkEnableOption "nixsys.home.profile.work";
  };

  config = lib.mkIf cfg.enable {

    nixsys.home = {

      profile = {
        base = enabled;
        devel = enabled;
      };

      desktop.xdg.directories = {
        music = ".xdg-music";
        pictures = ".xdg-pictures";
        videos = ".xdg-videos";
      };

      programs = {
        # Backup.
        restic = enabled;

        # Network clients.
        aria2 = enabled;
        wget = enabled;

        # Nix tools.
        nh = enabled;

        # Security.
        gpg = enabled;
        pass = enabled;
        pwgen = enabled;
      }
      // lib.optionalAttrs desktopEnabled {
        arandr = enabled;
        dbeaver-bin = enabled;
        evince = enabled;
        firefox = enabled;
        geany = enabled;
        google-chrome = enabled;
        gparted = enabled;
        maim = enabled;
        obsidian = enabled;
        slack = enabled;
        solaar = enabled;
        spotify = enabled;
        sxiv = enabled;
        thunderbird-latest = enabled;
        todoist-electron = enabled;
        zathura = enabled;
      }
      // lib.optionalAttrs (desktopEnabled && pulseaudioEnabled) {
        pavucontrol = enabled;
      }
      // lib.optionalAttrs (desktopEnabled && pipewireEnabled) {
        pwvucontrol = enabled;
      }
      // lib.optionalAttrs (desktopEnabled && btrfsEnabled) {
        btrfs-assistant = enabled;
      };

      services = {
        gpg-agent = enabled;
        ssh-agent = enabled;
      }
      // lib.optionalAttrs desktopEnabled {
        redshift = enabled;
      }
      // lib.optionalAttrs (desktopEnabled && audioEnabled) {
        mpris-proxy = enabled;
      };
    };
  };
}

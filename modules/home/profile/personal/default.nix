{
  config,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib.nixsys) enabled;
  libcfg = lib.nixsys.home;

  btrfsEnabled = osConfig.boot.supportedFilesystems.btrfs or false;
  pulseaudioEnabled = osConfig.nixsys.os.audio.pulseaudio.enable or false;
  pipewireEnabled = osConfig.nixsys.os.audio.pipewire.enable or false;
  audioEnabled = pulseaudioEnabled || pipewireEnabled;

  desktopEnabled = libcfg.isDesktopEnabled config;

  cfg = config.nixsys.home.profile.personal;
in
{
  options.nixsys.home.profile.personal = {
    enable = lib.mkEnableOption "nixsys.home.profile.personal";
  };

  config = lib.mkIf cfg.enable {

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
        chafa = enabled;
        imagemagick = enabled;
        timg = enabled;

        # Network clients.
        aria2 = enabled;
        elinks = enabled;
        wget = enabled;

        # Nix tools.
        nh = enabled;
        nxn = enabled;

        # Security.
        gpg = enabled;
        pass = enabled;
        pwgen = enabled;
        sequoia-sq = enabled;
      }
      // lib.optionalAttrs desktopEnabled {
        arandr = enabled;
        evince = enabled;
        firefox = enabled;
        geany = enabled;
        google-chrome = enabled;
        gparted = enabled;
        maim = enabled;
        nomacs = enabled;
        obsidian = enabled;
        openconnect = enabled;
        protonmail-bridge = enabled;
        protonvpn-gui = enabled;
        solaar = enabled;
        spotify = enabled;
        sxiv = enabled;
        thunderbird-latest = enabled;
        todoist-electron = enabled;
        veracrypt = enabled;
        vlc = enabled;
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
        mpd = enabled;
        mpris-proxy = enabled;
      };
    };
  };
}

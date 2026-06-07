{
  config,
  pkgs,
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

  desktopEnabled = libcfg.isDesktopEnabled config;

  cfg = config.nixsys.home.profile.work;
in
{
  options.nixsys.home.profile.work = {
    enable = lib.mkEnableOption "nixsys.home.profile.work";
  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      # Backup
      pkgs.restic

      # Media tools.
      pkgs.timg

      # Network clients.
      pkgs.wget

      # Nix tools.
      pkgs.nix-tree

      # Office tools.
      pkgs.presenterm
    ]
    ++ lib.optionals desktopEnabled [
      pkgs.arandr
      pkgs.dbeaver-bin
      pkgs.evince
      pkgs.firefox
      pkgs.geany
      pkgs.google-chrome
      pkgs.gparted
      pkgs.maim
      pkgs.slack
      pkgs.solaar
      pkgs.spotify
      pkgs.sxiv
      pkgs.thunderbird-latest
      pkgs.todoist-electron
      pkgs.zathura
    ]
    ++ lib.optionals (desktopEnabled && pulseaudioEnabled) [
      pkgs.pavucontrol
    ]
    ++ lib.optionals (desktopEnabled && pipewireEnabled) [
      pkgs.pwvucontrol
    ]
    ++ lib.optionals (desktopEnabled && btrfsEnabled) [
      pkgs.snapper-gui
    ];

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
        # Nix tools.
        nh = enabled;

        # Security.
        pass = enabled;
        pwgen = enabled;
      };

      services = {
        gpg-agent = enabled;
      };
    };
  };
}

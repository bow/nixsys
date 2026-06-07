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

  cfg = config.nixsys.home.profile.personal;
in
{
  options.nixsys.home.profile.personal = {
    enable = lib.mkEnableOption "nixsys.home.profile.personal";
  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      # Backup
      pkgs.restic

      # Chat.
      pkgs.weechat

      # Media tools.
      pkgs.pdftk
      pkgs.chafa
      pkgs.graphviz
      pkgs.imagemagick
      pkgs.timg

      # Network clients.
      pkgs.elinks
      pkgs.wget

      # Nix tools.
      pkgs.nix-tree

      # Local tools.
      pkgs.local.nxn
    ]
    ++ lib.optionals desktopEnabled [
      pkgs.arandr
      pkgs.evince
      pkgs.firefox
      pkgs.geany
      pkgs.google-chrome
      pkgs.gparted
      pkgs.maim
      pkgs.nomacs
      pkgs.openconnect
      pkgs.proton-vpn
      pkgs.protonmail-bridge
      pkgs.solaar
      pkgs.spotify
      pkgs.sxiv
      pkgs.thunderbird-latest
      pkgs.todoist-electron
      pkgs.veracrypt
      pkgs.vlc
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

      programs = {
        # Media players.
        ncmpcpp = enabled;

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

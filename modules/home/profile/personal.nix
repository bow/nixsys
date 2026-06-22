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

  imports = [
    ./layers/base.nix
    ./layers/devel.nix
  ];

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
      pkgs.local.psc
    ]
    ++ lib.optionals desktopEnabled [
      pkgs.arandr
      pkgs.evince
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

      programs = {
        # Media players.
        ncmpcpp = enabled;

        # Nix tools.
        nh = enabled;

        # Security.
        gpg = enabled;
        pass = enabled;
        pwgen = enabled;
      };

      services = {
        gpg-agent = enabled;
      };
    };
  };
}

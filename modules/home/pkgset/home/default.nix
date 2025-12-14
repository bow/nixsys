{
  config,
  lib,
  ...
}:
let
  inherit (lib.nixsys) enabled;

  cfg = config.nixsys.home.pkgset.home;
in
{
  options.nixsys.home.pkgset.home = {
    enable = lib.mkEnableOption "nixsys.home.pkgset.home";
  };
  config = lib.mkIf cfg.enable {

    nixsys.home = {

      pkgset = {
        minimal = enabled;
        devel = enabled;
      };

      programs = {
        # Backup.
        restic = enabled;

        # Chat.
        weechat = enabled;

        # Media editors.
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

        # Virtualization.
        distrobox = enabled;
        nerdctl = enabled;
        packer = enabled;
        virt-viewer = enabled;
      };
    };
  };
}

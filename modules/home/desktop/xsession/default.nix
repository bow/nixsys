{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.home;

  xorgEnabled = libcfg.isXorgEnabled config;

  cfg = config.nixsys.home.desktop.xsession;
in
{
  options.nixsys.home.desktop.xsession = {
    enable = lib.mkEnableOption "nixsys.home.desktop.xsession" // {
      default = xorgEnabled;
    };
    symlink-to-xinitrc = lib.mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable rec {
    xsession = {
      enable = true;
      scriptPath = ".xsession";
      initExtra = ''
        setxkbmap -option "compose:menu"
      '';
    };

    home.activation = lib.mkIf cfg.symlink-to-xinitrc {
      mkXinitRC = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ln -sf $VERBOSE_ARG $HOME/${xsession.scriptPath} $HOME/.xinitrc
      '';
    };
  };
}

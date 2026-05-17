{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.home;

  xorgEnabled = libcfg.isXorgEnabled config;

  cfg = config.nixsys.home.desktop.xsession;
in
{
  options.nixsys.home.desktop.pointer = {
    enable = lib.mkEnableOption "nixsys.home.desktop.pointer" // {
      default = xorgEnabled;
    };

    size = lib.mkOption {
      type = types.ints.positive;
      default = 22;
      description = "Sets home.pointerCursor.size";
    };

    themePackage = lib.mkPackageOption pkgs "bibata-cursors" { };

    themeName = lib.mkOption {
      types = types.str;
      default = "Bibata-Modern-Classic";
      description = "Sets home.pointerCursor.name";
    };
  };

  config = lib.mkIf cfg.enable {
    inherit (cfg) size;
    name = cfg.themeName;
    package = cfg.themePackage;
    x11.enable = xorgEnabled;
    gtk.enable = true;
  };
}

{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.home.desktop.xdg;
in
{
  options.nixsys.home.desktop.xdg = {
    enable = lib.mkEnableOption "nixsys.home.desktop.xdg";
    create-directories = lib.mkOption {
      default = true;
      type = types.bool;
      description = "Sets xdg.userDirs.createDirectories";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      enable = true;
      userDirs = with config.home; {
        enable = true;
        createDirectories = cfg.create-directories;
        desktop = "${homeDirectory}/dsk";
        download = "${homeDirectory}/dl";
        templates = "${homeDirectory}/.xdg-templates";
        publicShare = "${homeDirectory}/.xdg-public";
        documents = "${homeDirectory}/docs";
        music = "${homeDirectory}/music";
        pictures = "${homeDirectory}/pics";
        videos = "${homeDirectory}/vids";
      };
    };
  };
}

{
  config,
  lib,
  user,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.home;

  desktopEnabled = libcfg.isDesktopEnabled config;
  shellBash = libcfg.isShellBash user;

  cfg = config.nixsys.home.desktop.xdg;
in
{
  options.nixsys.home.desktop.xdg = {
    enable = lib.mkEnableOption "nixsys.home.desktop.xdg" // {
      default = desktopEnabled;
    };
    create-directories = lib.mkOption {
      default = true;
      type = types.bool;
      description = "Sets xdg.userDirs.createDirectories";
    };
    directories =
      let
        mkDirOption =
          dirName:
          lib.mkOption {
            type = types.str;
            default = dirName;
          };
      in
      {
        desktop = mkDirOption "dsk";
        download = mkDirOption "dl";
        templates = mkDirOption ".xdg-templates";
        public-share = mkDirOption ".xdg-public";
        documents = mkDirOption "docs";
        music = mkDirOption "music";
        pictures = mkDirOption "pics";
        videos = mkDirOption "vids";
      };
    enable-bash-integration = lib.mkOption {
      type = types.bool;
      default = shellBash;
    };
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      enable = true;
      userDirs = with config.home; {
        enable = true;
        createDirectories = cfg.create-directories;
        desktop = "${homeDirectory}/${cfg.directories.desktop}";
        download = "${homeDirectory}/${cfg.directories.download}";
        templates = "${homeDirectory}/${cfg.directories.templates}";
        publicShare = "${homeDirectory}/${cfg.directories.public-share}";
        documents = "${homeDirectory}/${cfg.directories.documents}";
        music = "${homeDirectory}/${cfg.directories.music}";
        pictures = "${homeDirectory}/${cfg.directories.pictures}";
        videos = "${homeDirectory}/${cfg.directories.videos}";
      };
    };

    programs.bash = lib.optionalAttrs cfg.enable-bash-integration {
      bashrcExtra = with config.home; ''
        alias dl='cd ${homeDirectory}/${cfg.directories.download}'
        alias dk='cd ${homeDirectory}/${cfg.directories.desktop}'
        alias dsk='cd ${homeDirectory}/${cfg.directories.desktop}'
      '';
    };
  };
}

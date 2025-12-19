{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixsys.home.programs.thunar;
in
{
  options.nixsys.home.programs.thunar = {
    enable = lib.mkEnableOption "nixsys.home.programs.thunar";
    package = lib.mkPackageOption pkgs "xfce.thunar" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.xfce.thunar
      pkgs.xfce.thunar-archive-plugin
      pkgs.xfce.thunar-dropbox-plugin
      pkgs.xfce.thunar-volman
    ];
  };
}

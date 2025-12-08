{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.home;

  desktopEnabled = libcfg.isDesktopEnabled config;
  pulseaudioEnabled = libcfg.isPulseaudioEnabled config;

  cfg = config.nixsys.home.programs.pavucontrol;
in
{
  options.nixsys.home.programs.pavucontrol = {
    enable = lib.mkEnableOption "nixsys.home.programs.pavucontrol" // {
      default = desktopEnabled && pulseaudioEnabled;
    };
    package = lib.mkPackageOption pkgs.unstable "pavucontrol" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}

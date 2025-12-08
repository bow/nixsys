{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.home;

  pulseaudioEnabled = libcfg.isPulseaudioEnabled config;

  cfg = config.nixsys.home.programs.pulsemixer;
in
{
  options.nixsys.home.programs.pulsemixer = {
    enable = lib.mkEnableOption "nixsys.home.programs.pulsemixer" // {
      default = pulseaudioEnabled;
    };
    package = lib.mkPackageOption pkgs.unstable "pulsemixer" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}

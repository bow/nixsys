{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  libcfg = lib.nixsys.home;

  desktopEnabled = libcfg.isDesktopEnabled config;

  cfg = config.nixsys.home.services.redshift;
in
{
  options.nixsys.home.services.redshift = {
    enable = lib.mkEnableOption "nixsys.home.services.redshift" // {
      default = desktopEnabled;
    };
    package = lib.mkPackageOption pkgs "redshift" { };
  };

  config = lib.mkIf cfg.enable {
    services.redshift = {
      enable = true;

      inherit (user.location) latitude longitude;
      provider = "manual";
      settings = {
        redshift = {
          fade = 1;
        };
      };
      temperature = {
        day = 5800;
        night = 4000;
      };
    };
  };
}

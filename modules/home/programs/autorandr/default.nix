{
  config,
  options,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.home;

  i3Enabled = libcfg.isI3Enabled config;
  i3Package = libcfg.getI3Package config;

  cfg = config.nixsys.home.programs.autorandr;
in
{
  options.nixsys.home.programs.autorandr = {
    enable = lib.mkEnableOption "nixsys.home.programs.autorandr";
    package = lib.mkPackageOption pkgs "autorandr" { };
    inherit (options.programs.autorandr) profiles;
  };

  config = lib.mkIf cfg.enable {

    programs.autorandr = {
      enable = true;

      inherit (cfg) package profiles;
      hooks = {
        postswitch = lib.optionalAttrs i3Enabled {
          "restart-i3" = "${i3Package}/bin/i3-msg restart";
        };
      };
    };
  };
}

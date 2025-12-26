{
  config,
  lib,
  options,
  ...
}:
let
  libcfg = lib.nixsys.os;

  i3Enabled = libcfg.isI3Enabled config;
  homeCfg = libcfg.getHomeConfigOrNull config;

  cfg = config.nixsys.os.display.autorandr;
in
{
  options.nixsys.os.display.autorandr = {
    enable = lib.mkEnableOption "nixsys.os.display.autorandr" // {
      default = i3Enabled;
    };
    inherit (options.services.autorandr) profiles;
  };

  config = lib.mkIf cfg.enable {

    services.autorandr = {
      enable = true;

      inherit (cfg) profiles;
      hooks.postswitch = lib.optionalAttrs i3Enabled {
        "restart-i3" = "${homeCfg.desktop.i3.package}/bin/i3-msg restart";
      };
    };
  };
}

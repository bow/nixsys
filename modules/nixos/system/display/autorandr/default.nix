{
  config,
  lib,
  options,
  ...
}:
let
  libcfg = lib.nixsys.nixos;

  i3Enabled = libcfg.isI3Enabled config;
  homeCfg = libcfg.getHomeConfigOrNull config;

  cfg = config.nixsys.system.display.autorandr;
in
{
  options.nixsys.system.display.autorandr = {
    enable = lib.mkEnableOption "nixsys.system.display.autorandr" // {
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

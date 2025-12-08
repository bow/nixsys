{
  config,
  lib,
  ...
}:
let
  libcfg = lib.nixsys.nixos;

  xorgEnabled = libcfg.isXorgEnabled config;

  cfg = config.nixsys.system.touchpad;
in
{
  options.nixsys.system.touchpad = {
    enable = lib.mkEnableOption "nixsys.system.touchpad";
  };

  config = lib.mkIf (cfg.enable && xorgEnabled) {
    services.libinput = {
      enable = true;
      touchpad = {
        accelProfile = "adaptive";
        accelSpeed = "0.65";
        clickMethod = "clickfinger";
        horizontalScrolling = false;
        naturalScrolling = true;
        scrollMethod = "twofinger";
        tapping = true;
        tappingButtonMap = "lmr";
        additionalOptions = ''
          Option "TappingDrag" "on"
        '';
      };
    };
  };
}

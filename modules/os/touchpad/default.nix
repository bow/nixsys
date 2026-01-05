{
  config,
  lib,
  ...
}:
let
  cfg = config.nixsys.os.touchpad;
in
{
  options.nixsys.os.touchpad = {
    enable = lib.mkEnableOption "nixsys.os.touchpad";
  };

  config = lib.mkIf cfg.enable {
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

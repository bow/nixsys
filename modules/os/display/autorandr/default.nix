{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.nixsys.os.display.autorandr;
in
{
  options.nixsys.os.display.autorandr = {
    enable = lib.mkEnableOption "nixsys.os.display.autorandr" // {
      default = config.nixsys.os.users.main.session.xorg.enable;
    };
    inherit (options.services.autorandr) profiles;
  };

  config = lib.mkIf cfg.enable {

    services.autorandr = {
      enable = true;
      inherit (cfg) profiles;
    };

    systemd.services.autorandr = {
      startLimitIntervalSec = lib.mkForce 12;
      startLimitBurst = lib.mkForce 3;
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 4;
      };
    };
  };
}

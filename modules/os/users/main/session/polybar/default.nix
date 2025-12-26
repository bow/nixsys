{
  config,
  lib,
  ...
}:
let
  i3Cfg = config.nixsys.os.users.main.session.i3;

  cfg = config.nixsys.os.users.main.session.polybar;
in
{
  options.nixsys.os.users.main.session.polybar = {
    enable = lib.mkEnableOption "nixsys.user.main.session.polybar" // {
      default = i3Cfg.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      udev.enable = lib.mkDefault true;
      upower.enable = lib.mkDefault true;
    };
  };
}

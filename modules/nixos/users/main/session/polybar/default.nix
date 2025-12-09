{
  config,
  lib,
  ...
}:
let
  i3Cfg = config.nixsys.users.main.session.i3;

  cfg = config.nixsys.users.main.session.polybar;
in
{
  options.nixsys.users.main.session.polybar = {
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

{
  config,
  lib,
  ...
}:
{
  options.nixsys.os.users.main.session.xorg = {
    enable = lib.mkEnableOption "nixsys.os.users.main.session.xorg" // {
      default = config.nixsys.os.users.main.session.i3.enable;
    };
  };
}

{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.nixsys.enable {
    services.dbus.implementation = "broker";
  };
}

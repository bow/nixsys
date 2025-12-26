{
  config,
  lib,
  ...
}:
let
  libcfg = lib.nixsys.os;

  user = libcfg.getMainUserOrNull config;
in
{
  config = lib.mkIf config.nixsys.os.enable {
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = if (user != null) then user.timezone else "UTC";
  };
}

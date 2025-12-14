{
  lib,
  ...
}:
let
  inherit (lib.nixsys) enabled;
in
{
  nixsys.home = {
    desktop.i3 = enabled;
    devel = enabled;
    pkgset.home = enabled;
    theme.current = enabled;
    services = {
      redshift = enabled;
    };
    system = {
      docker = enabled;
      pulseaudio = enabled;
      bluetooth = enabled;
    };
  };
}

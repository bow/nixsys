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
    theme.north-01 = enabled;
    system = {
      docker = enabled;
      pulseaudio = enabled;
    };
  };
}

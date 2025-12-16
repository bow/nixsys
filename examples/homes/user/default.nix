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
    profile.personal = enabled;
    theme.current = enabled;
    system = {
      docker = enabled;
      pulseaudio = enabled;
      bluetooth = enabled;
    };
  };
}

{
  lib,
  ...
}:
let
  inherit (lib.nixsys) enabled;
in
{
  nixsys.home = {
    profile.personal = enabled;
    system = {
      docker = enabled;
      pulseaudio = enabled;
      bluetooth = enabled;
    };
  };
}

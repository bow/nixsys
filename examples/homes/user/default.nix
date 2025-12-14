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
    theme.current = enabled;
    services = {
      redshift = enabled;
    };
    suites = {
      backup = enabled;
      base = enabled;
      chat = enabled;
      media-editors = enabled;
      network-clients = enabled;
      ops = enabled;
      security = enabled;
      virtualization = enabled;
    };
    system = {
      docker = enabled;
      pulseaudio = enabled;
      bluetooth = enabled;
    };
  };
}

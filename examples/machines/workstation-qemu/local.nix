{
  lib,
  ...
}:
let
  inherit (lib.nixsys) enabled enabledWith;
in
{
  nixsys = {
    system = {
      servers.ssh = enabled;
      virtualization.guest = enabledWith {
        type = "qemu";
      };
    };
    users.main = {
      home-manager = enabledWith {
        desktop.i3 = enabledWith {
          mod-key = "Mod1";
        };
        profile.personal = enabled;
      };
    };
  };
}

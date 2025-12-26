{
  lib,
  user,
  ...
}:
let
  inherit (lib.nixsys) enabled enabledWith;
in
{
  home-manager.users.${user.name}.imports = [ ./home.nix ];

  nixsys.os = enabledWith {
    servers.ssh = enabled;
    users.main.home-manager.desktop.i3 = enabled;
    virtualization.guest = enabledWith {
      type = "qemu";
    };
  };
}

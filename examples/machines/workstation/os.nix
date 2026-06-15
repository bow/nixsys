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

  system.stateVersion = "25.05";

  nixsys.os = enabledWith {
    profile.workstation = enabled;
    servers.ssh = enabled;
    users.main.home-manager.desktop.i3 = enabled;
  };
}

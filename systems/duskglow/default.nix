{
  outputs,
  lib,
  user,
  hostname,
  ...
}:
let
  inherit (lib.nixsys) enabled enabledWith;
in
{
  system.stateVersion = "25.05";

  imports = [
    outputs.nixosModules.nixsys
  ];

  nixsys = enabledWith {
    system = {
      inherit hostname;
      profile = "workstation";
      touchpad = enabled;

      boot.systemd = enabled;
      networking.networkmanager = enabled;
      nix.nixos-cli = enabled;
      servers.ssh = enabled; # FIXME: Remove when ready.
      virtualization.docker = enabled;
    };
    users.main = {
      inherit (user)
        name
        full-name
        email
        city
        timezone
        ;
      trusted = true;
      session.greetd = enabledWith {
        settings.auto-login = true;
      };
      home-manager = enabledWith {
        desktop.i3 = enabled;
        devel = enabled;
        theme.current = enabled;
      };
    };
  };
}

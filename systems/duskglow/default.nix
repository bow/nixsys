{
  lib,
  user,
  hostname,
  ...
}:
let
  inherit (lib.nixsys) enabled enabledWith;
in
{
  nixsys = enabledWith {
    system = {
      inherit hostname;
      profile = "workstation";
      touchpad = enabled;

      boot.systemd = enabled;
      bluetooth = enabled;
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
        location
        timezone
        ;
      trusted = true;
      session.greetd = enabledWith {
        settings.auto-login = true;
      };
      home-manager = enabledWith {
        desktop.i3 = enabled;
        devel = enabled;
        services = {
          mpris-proxy = enabled;
          redshift = enabled;
        };
        theme.current = enabled;
      };
    };
  };

  system.stateVersion = "25.05";
}

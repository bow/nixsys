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
      virtualization = {
        docker = enabled;
        libvirtd = enabled;
      };
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
        programs = {
          ncmpcpp = enabled;
        };
        services = {
          mpd = enabled;
          mpris-proxy = enabled;
          redshift = enabled;
        };
        theme.current = enabled;
      };
    };
  };

  system.stateVersion = "25.05";
}

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
      bluetooth = enabled;
      boot.systemd = enabled;
      networking.networkmanager = enabled;
      nix.nixos-cli = enabled;
      touchpad = enabled;
      udev.rulesets = {
        qmk = enabled;
        wake-on-device = enabled;
      };
      virtualization.host = {
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
        shell
        timezone
        ;
      trusted = true;
      session.greetd = enabledWith {
        settings.auto-login = true;
      };
      home-manager = enabledWith {
        desktop.i3 = enabled;
        profile.personal = enabled;
      };
    };
  };

  system.stateVersion = "25.05";
}

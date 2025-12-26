{
  config,
  lib,
  user,
  hostname,
  ...
}:
let
  inherit (lib.nixsys) enabled enabledWith;
  libcfg = lib.nixsys.os;
  btrfsEnabled = libcfg.isBTRFSEnabled config;
in
{
  nixsys.os = enabledWith {
    inherit hostname;
    backup.snapper = {
      enable-home-snapshots = btrfsEnabled;
    };
    bluetooth = enabled;
    boot.systemd = enabled;
    networking.networkmanager = enabled;
    nix.nixos-cli = enabled;
    touchpad = enabled;
    udev.rulesets = {
      qmk = enabled;
      wake-on-device = enabled;
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
      home-manager = enabled;
    };
    virtualization.host = {
      docker = enabled;
      libvirtd = enabled;
    };
  };

  system.stateVersion = "25.05";
}

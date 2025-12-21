{
  config,
  lib,
  user,
  hostname,
  ...
}:
let
  inherit (lib.nixsys) enabled enabledWith;
  libcfg = lib.nixsys.nixos;
  btrfsEnabled = libcfg.isBTRFSEnabled config;
in
{
  nixsys = enabledWith {
    system = {
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
      home-manager = enabled;
    };
  };

  system.stateVersion = "25.05";
}

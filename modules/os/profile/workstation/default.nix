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

  cfg = config.nixsys.os.profile.workstation;
in
{
  options.nixsys.os.profile.workstation = {
    enable = lib.mkEnableOption "nixsys.os.profile.workstation";
  };

  config = lib.mkIf cfg.enable {
    boot.extraModprobeConfig =
      with config.boot;
      lib.optionalString (builtins.elem "kvm-intel" kernelModules) "options kvm_intel nested=1"
      + lib.optionalString (builtins.elem "kvm-amd" kernelModules) "options kvm_amd nested=1";

    nixsys.os = enabledWith {
      inherit hostname;
      backup.snapper = {
        enable-home-snapshots = btrfsEnabled;
      };
      bluetooth = enabled;
      boot.systemd = enabled;
      networking.networkmanager = enabled;
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
  };
}

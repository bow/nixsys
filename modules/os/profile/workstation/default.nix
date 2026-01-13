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

    # FIXME: Only do this if the home-manager setup enables SSH agents.
    security.sudo.extraConfig = ''
      Defaults    env_keep+=SSH_AUTH_SOCK
    '';

    nixsys.os = enabledWith {
      inherit hostname;
      audio.pipewire = enabled;
      backup.snapper = {
        enable-home-snapshots = btrfsEnabled;
      };
      bluetooth = enabled;
      boot.systemd = enabled;
      keyboard.qmk = enabled;
      networking.networkmanager = enabled;
      touchpad = enabled;
      udev.rulesets.wake-on-device = enabled;
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
        session.greetd = {
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

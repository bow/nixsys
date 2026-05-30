{
  config,
  lib,
  user,
  hostname,
  ...
}:
let
  inherit (lib.nixsys) enabled enabledWith;

  btrfsEnabled = config.boot.supportedFilesystems.btrfs or false;

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

    system.activationScripts =
      let
        mainUser = config.nixsys.os.users.main;
        persistDir = "/persist";
      in
      lib.optionalAttrs (mainUser != null) {
        createUserDataDir = ''
          mkdir -p ${persistDir}/${mainUser.name}
          chown ${mainUser.name}:root ${persistDir}/${mainUser.name}
          chmod 0700 ${persistDir}/${mainUser.name}
        '';
      };

    virtualisation.vmVariant = lib.mkDefault {
      cores = 8;
      diskSize = 80 * 1024;
      memorySize = 8192 + 4096;
      resolution = {
        x = 1600;
        y = 1900;
      };
    };

    nixsys.os = enabledWith {
      inherit hostname;
      audio.pipewire = enabled;
      backup.snapper = {
        enable-home-snapshots = btrfsEnabled;
        enable-machine-data-dir-snapshots = btrfsEnabled;
      };
      bluetooth = enabled;
      boot.systemd = enabled;
      keyboard.qmk = enabled;
      networking.networkmanager = enabled;
      nix.gc-max-retention-days = 28;
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
  };
}

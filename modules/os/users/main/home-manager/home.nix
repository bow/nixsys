{
  config,
  lib,
  outputs,
  user,
  asStandalone ? true,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.home;
in
{
  options.nixsys.home = {

    session-variables = lib.mkOption {
      type = types.attrs;
      default = { };
    };

    os = lib.mkOption {
      default = { };
      description = "Container for copied os-level settings";
      # Make this a typed submodule to prevent this from becoming a random bag of stuff.
      type = types.submodule {
        options = {
          bluetooth.enable = lib.mkEnableOption "nixsys.home.os.bluetooth";
          btrfs.enable = lib.mkEnableOption "nixsys.home.os.btrfs";
          docker.enable = lib.mkEnableOption "nixsys.home.os.docker";
          libvirtd.enable = lib.mkEnableOption "nixsys.home.os.libvirtd";
          pulseaudio.enable = lib.mkEnableOption "nixsys.home.os.pulseaudio";
        };
      };
    };
  };

  config = {
    home = {
      stateVersion = "25.05";
      username = user.name;
      homeDirectory = user.home-directory;
      preferXdgDirectories = true;
      sessionVariables = cfg.session-variables;

      # FIXME: Find out where to best put this.
      file.".config/libvirt/qemu.conf" = lib.mkIf config.nixsys.home.os.libvirtd.enable {
        text = ''
          nvram = [
            "/run/libvirt/nix-ovmf/edk2-aarch64-code.fd:/run/libvirt/nix-ovmf/edk2-arm-vars.fd",
            "/run/libvirt/nix-ovmf/edk2-x86_64-code.fd:/run/libvirt/nix-ovmf/edk2-i386-vars.fd"
          ]
        '';
      };
    };

    nixpkgs = lib.mkIf asStandalone {
      overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
      ];
      config.allowUnfree = true;
    };

    programs = {
      home-manager.enable = true;
    };

    # Reload systemd units on config change.
    systemd.user.startServices = "sd-switch";
  };
}

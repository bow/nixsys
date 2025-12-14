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
in
{
  options.nixsys.home.system = lib.mkOption {
    default = { };
    description = "Container for copied system-level settings";
    # Make this a typed submodule to prevent this from becoming a random bag of stuff.
    type = types.submodule {
      options = {
        bluetooth.enable = lib.mkEnableOption "nixsys.home.system.bluetooth";
        docker.enable = lib.mkEnableOption "nixsys.home.system.docker";
        libvirtd.enable = lib.mkEnableOption "nixsys.home.system.libvirtd";
        pulseaudio.enable = lib.mkEnableOption "nixsys.home.system.pulseaudio";
      };
    };
  };

  config = {
    home = {
      stateVersion = "25.05";
      username = user.name;
      homeDirectory = user.home-directory;
      preferXdgDirectories = true;

      # FIXME: Find out where to best put this.
      file.".config/libvirt/qemu.conf" = lib.mkIf config.nixsys.home.system.libvirtd.enable {
        text = ''
          nvram = [
            "/run/libvirt/nix-ovmf/edk2-aarch64-code.fd:/run/libvirt/nix-ovmf/edk2-arm-vars.fd",
            "/run/libvirt/nix-ovmf/edk2-x86_64-code.fd:/run/libvirt/nix-ovmf/edk2-i386-vars.fd"
          ]
        '';
      };
    };

    nixpkgs = lib.mkIf asStandalone {
      overlays = builtins.attrValues outputs.overlays;
      config.allowUnfree = true;
    };

    programs = {
      home-manager.enable = true;
    };

    # Reload systemd units on config change.
    systemd.user.startServices = "sd-switch";
  };
}

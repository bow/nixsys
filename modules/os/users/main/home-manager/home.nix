{
  config,
  lib,
  osConfig,
  outputs,
  user,
  asStandalone ? true,
  ...
}:
let
  inherit (lib) types;

  libvirtdEnabled = osConfig.nixsys.os.virtualization.host.libvirtd.enable or false;

  cfg = config.nixsys.home;
in
{
  options.nixsys.home = {
    session-variables = lib.mkOption {
      type = types.attrs;
      default = { };
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
      file.".config/libvirt/qemu.conf" = lib.mkIf libvirtdEnabled {
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

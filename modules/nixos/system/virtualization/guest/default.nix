{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.nixos;

  xorgEnabled = libcfg.isXorgEnabled config;

  cfg = config.nixsys.system.virtualization.guest;
in
{
  options.nixsys.system.virtualization.guest = {
    enable = lib.mkEnableOption "nixsys.system.virtualization.guest";
    type = lib.mkOption {
      type = types.enum [ "qemu" ];
      description = "The type of the guest agent to run";
    };
  };

  config = lib.mkIf cfg.enable {
    services.qemuGuest.enable = cfg.type == "qemu";
    services.spice-vdagentd.enable = xorgEnabled;
  };
}

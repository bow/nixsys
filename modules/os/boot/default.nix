{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.os.boot;
in
{
  options.nixsys.os.boot = {
    enable = lib.mkEnableOption "nixsys.os.boot" // {
      default = config.nixsys.os.boot.systemd.enable;
    };

    enable-systemd = lib.mkOption {
      type = types.bool;
      default = true;
    };

    quiet = lib.mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      consoleLogLevel = if cfg.quiet then 0 else 4;
      initrd = {
        systemd.enable = cfg.enable-systemd;
        verbose = !cfg.quiet;
      };
      kernelParams = lib.optionals cfg.quiet [ "quiet" ];
      tmp.cleanOnBoot = true;
    };
  };
}

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

    quiet = lib.mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      consoleLogLevel = if cfg.quiet then 0 else 4;
      initrd.verbose = !cfg.quiet;
      kernelParams = [ "nomodeset" ] ++ lib.optionals cfg.quiet [ "quiet" ];
      tmp.cleanOnBoot = true;
    };
  };
}

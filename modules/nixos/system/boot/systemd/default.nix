{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.system.boot.systemd;
in
{
  options.nixsys.system.boot.systemd = {
    enable = lib.mkEnableOption "Enable boot module";

    console-mode = lib.mkOption {
      description = "Sets boot.loader.systemd-boot.consoleMode";
      type = types.str;
      default = "auto";
    };

    loader-timeout = lib.mkOption {
      description = "Sets boot.loader.timeout";
      type = types.nullOr types.ints.positive;
      default = 1;
    };

    num-entries-max = lib.mkOption {
      type = types.ints.positive;
      default = 30;
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
      kernelParams = lib.optionals cfg.quiet [ "quiet" ];
      loader = {
        timeout = lib.mkForce cfg.loader-timeout;
        systemd-boot = {
          enable = true;
          configurationLimit = cfg.num-entries-max;
          consoleMode = cfg.console-mode;
        };
        efi.canTouchEfiVariables = true;
      };
      tmp.cleanOnBoot = true;
    };
  };
}

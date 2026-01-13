{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.os.boot.systemd;
in
{
  options.nixsys.os.boot.systemd = {
    enable = lib.mkEnableOption "nixsys.os.boot.systemd";

    console-mode = lib.mkOption {
      description = "Sets boot.loader.systemd-boot.consoleMode";
      type = types.str;
      default = "auto";
    };

    num-entries-max = lib.mkOption {
      type = types.ints.positive;
      default = 30;
    };

    timeout = lib.mkOption {
      description = "Sets boot.loader.timeout";
      type = types.nullOr types.ints.positive;
      default = 1;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = lib.mkDefault true;
      timeout = lib.mkForce cfg.loader-timeout;
      systemd-boot = {
        enable = true;
        configurationLimit = cfg.num-entries-max;
        consoleMode = cfg.console-mode;
      };
    };
  };
}

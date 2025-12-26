{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.os.security.clamav;
in
{
  options.nixsys.os.security.clamav = {
    enable = lib.mkEnableOption "nixsys.os.security.clamav";
    package = lib.mkPackageOption pkgs "clamav" { };

    enable-scanner = lib.mkOption {
      type = types.bool;
      default = false;
    };
    enable-updater = lib.mkOption {
      type = types.bool;
      default = true;
    };
    enable-on-access-scan = lib.mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {

    services.clamav = {
      daemon.enable = true;
      clamonacc.enable = cfg.enable-on-access-scan;
      scanner.enable = cfg.enable-scanner;
      updater.enable = cfg.enable-updater;
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.home.programs.gpg;
in
{
  options.nixsys.home.programs.gpg = {
    enable = lib.mkEnableOption "nixsys.home.programs.gpg";

    mutable-keys = lib.mkOption {
      description = "Sets programs.gpg.mutableKeys";
      type = types.bool;
      default = true;
    };

    mutable-trust = lib.mkOption {
      description = "Sets programs.gpg.mutableTrust";
      type = types.bool;
      default = true;
    };

    package = lib.mkPackageOption pkgs "gnupg" { };
  };

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;

      inherit (cfg) package;
      mutableKeys = cfg.mutable-keys;
      mutableTrust = cfg.mutable-trust;
    };
  };
}

{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.home;

  shellBash = libcfg.isShellBash user;

  cfg = config.nixsys.home.programs.gpg;
in
{
  options.nixsys.home.programs.gpg = {
    enable = lib.mkEnableOption "nixsys.home.programs.gpg";

    enable-bash-integration = lib.mkOption {
      type = types.bool;
      default = shellBash;
    };

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

    programs.bash = lib.optionalAttrs cfg.enable-bash-integration {
      bashrcExtra = ''
        function show-gpg-ssh-key() {
            gpg --export-ssh-key $(gpg -K --with-colons | awk -F: '/^sec/{print $5}')
        }
      '';
    };
  };
}

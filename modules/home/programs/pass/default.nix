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

  cfg = config.nixsys.home.programs.pass;
in
{
  options.nixsys.home.programs.pass = {
    enable = lib.mkEnableOption "nixsys.home.programs.pass";

    enable-bash-integration = lib.mkOption {
      type = types.bool;
      default = shellBash;
    };

    package = lib.mkPackageOption pkgs "pass" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.bash = lib.optionalAttrs cfg.enable-bash-integration {
      bashrcExtra = ''
        function genpass() {
            local passpath=''${1}
            local length=''${2:-32}

            if [ -z "''${passpath}" ]; then
              printf "%s\n" "Error: missing pass path" >&2
              return 1
            fi

            ${cfg.package}/bin/pass generate "''${passpath}" ''${length}
            ${cfg.package}/bin/pass edit "''${passpath}"
        }

        function addpass() {
            local passpath=''${1}

            if [ -z "''${passpath}" ]; then
              printf "%s\n" "Error: missing pass path" >&2
              return 1
            fi

            ${cfg.package}/bin/pass insert -m "''${passpath}"
            ${cfg.package}/bin/pass show -c1 "''${passpath}"
        }
      '';
    };
  };
}

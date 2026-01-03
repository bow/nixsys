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

  cfg = config.nixsys.home.programs.pwgen;
in
{
  options.nixsys.home.programs.pwgen = {
    enable = lib.mkEnableOption "nixsys.home.programs.pwgen";

    enable-bash-integration = lib.mkOption {
      type = types.bool;
      default = shellBash;
    };

    package = lib.mkPackageOption pkgs "pwgen" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.bash = lib.optionalAttrs cfg.enable-bash-integration {
      bashrcExtra = ''
        function genpw-pgpass-md5() {
            local user="''${1}"
            if [ -z "''${user}" ]; then
              printf "%s\n" "Error: missing user" >&2
              return 1
            fi

            local password="''${2}"
            if [ -z "''${password}" ]; then
              printf "%s\n" "Error: missing actual password" >&2
              return 1
            fi

            printf "md5%s\n" "''$(echo -n "''${password}''${user}" | md5sum | awk '{print ''$1}')"
        }

        function genpw-esc() {
            ${cfg.package}/bin/pwgen -r\'\"\#\`\''${} -cnysB ''${1:-128} 1
        }

        function genpw-user() {
            ${cfg.package}/bin/pwgen -cnsB ''${1:-96} 1
        }
      '';
    };
  };
}


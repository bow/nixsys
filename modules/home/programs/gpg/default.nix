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

  gitEnabled = libcfg.isGitEnabled config;
  shellBash = libcfg.isShellBash user;
  yubikeyEnabled = libcfg.isYubikeyEnabled config;

  cfg = config.nixsys.home.programs.gpg;
in
{
  options.nixsys.home.programs.gpg = {
    enable = lib.mkEnableOption "nixsys.home.programs.gpg";

    enable-bash-integration = lib.mkOption {
      type = types.bool;
      default = shellBash;
    };

    enable-git-integration = lib.mkOption {
      type = types.bool;
      default = gitEnabled;
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

    programs =
      let
        git-config-path = "${user.home-directory}/.config/git/gpg";
      in
      {

        gpg = {
          enable = true;

          inherit (cfg) package;
          mutableKeys = cfg.mutable-keys;
          mutableTrust = cfg.mutable-trust;

          scdaemonSettings = lib.mkIf yubikeyEnabled {
            disable-ccid = true;
          };
        };

        bash = lib.mkIf cfg.enable-bash-integration {
          profileExtra =
            let
              export-gpg-signing-key-sh = pkgs.writeShellScriptBin "export-gpg-signing-key.sh" ''
                set -ueo pipefail

                function exit_msg() {
                    printf "%s\n" "''${1}" >&2
                    exit 0
                }

                function export_signing_key() {
                    local target="${git-config-path}"

                    local selected_key_id=""
                    local gitconfig=""

                    local first=1

                    for key_id in $(${cfg.package}/bin/gpg --list-secret-keys --keyid-format long | ${pkgs.gawk}/bin/awk '/\[[CEA]?S[CEA]?\]/{ print $2 }' | ${pkgs.coreutils}/bin/cut -d/ -f2); do
                        if [ ''${first} -lt 1 ]; then
                            printf "Warning: %s\n" "Key ID ''${key_id} is not used for git signing because of key ID ''${selected_key_id}" >&2
                            continue
                        fi
                        selected_key_id="''${key_id}"
                        gitconfig=$(
                            ${pkgs.coreutils}/bin/cat <<EOF
                # vim: set ft=gitconfig:
                [user]
                    signingkey = ''${selected_key_id}!
                [gpg]
                    format = "openpgp"
                [commit]
                    gpgSign = true
                [tag]
                    gpgSign = true
                EOF
                        )
                        first=0
                    done

                    if [[ -z "''${gitconfig}" ]]; then
                        exit_msg "Skipping git signing config creation - no keys available"
                    fi

                    if [[ -f "''${target}" ]]; then
                        if [[ "$(cat "''${target}")" == "''${gitconfig}" ]]; then
                            exit_msg "File ''${target} unchanged"
                        fi
                        printf "%s\n" "''${gitconfig}" >"''${target}"
                        exit_msg "File ''${target} updated with user.signingkey=''${selected_key_id}"
                    fi

                    printf "%s\n" "''${gitconfig}" >"''${target}"
                    exit_msg "File ''${target} created with user.signingkey=''${selected_key_id}"
                }

                export_signing_key
              '';
            in
            ''
              ${export-gpg-signing-key-sh}/bin/export-gpg-signing-key.sh
            '';

          bashrcExtra = ''
            function show-gpg-ssh-key() {
                gpg --export-ssh-key $(gpg -K --with-colons | awk -F: '/^sec/{print $5}')
            }
          '';
        };

        git.includes = lib.mkIf cfg.enable-git-integration [
          { path = "${git-config-path}"; }
        ];
      };
  };
}

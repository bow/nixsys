{
  lib,
  callPackage,
  symlinkJoin,
  writeShellScriptBin,
  writeTextFile,
}:
let
  name = "nxn";

  version = "0.1.0";

  subcmds = [
    (callPackage ./subcmds/show-deps.nix { })
  ];

  script =
    let
      usageHelp = lib.concatMapStrings (cmd: "  ${cmd.name}\t${cmd.description}\n") subcmds;

      cmdCases = lib.concatMapStrings (cmd: ''
        ${cmd.name})
          shift
          ${cmd.cmdFuncName} "$@"
          ;;
      '') subcmds;

      subcmdBodies = lib.concatMapStrings (cmd: cmd.body) subcmds;
    in
    writeShellScriptBin name ''
      set -ueo pipefail

      readonly CMD="''${0##*/}"
      readonly VERSION="${version}"

      ${subcmdBodies}

      usage() {
        cat <<EOF
      Usage: ''${CMD} [OPTIONS] COMMAND [COMMAND OPTIONS]

      ${name} executes nix commands.

      Commands:
      ${usageHelp}
      Options:
        -h, --help       Show this help message and exit
        -v, --version    Show version and exit

      Run "''${CMD} COMMAND --help" for more information on a command.
      EOF
      }

      if [[ $# -eq 0 ]]; then
        usage >&2
        exit 1
      fi

      case "''$1" in
      ${cmdCases}
      -h | --help)
        usage
        exit 0
        ;;
      -v | --version)
        echo "''${CMD} ''${VERSION}"
        exit 0
        ;;
      -*)
        echo "''${CMD}: error: unknown option: ''$1" >&2
        usage >&2
        exit 1
        ;;
      *)
        echo "''${CMD}: error: unknown command: ''$1" >&2
        usage >&2
        exit 1
        ;;
      esac
    '';

  bash-completion =
    let
      subcmdNames = lib.concatMapStringsSep " " (cmd: "${cmd.name} ") subcmds;
      completionCases = lib.concatMapStrings (cmd: cmd.completion) subcmds;
    in
    writeTextFile {
      name = "${name}-bash-completion";
      destination = "/share/bash-completion/completions/${name}";
      text = ''
        _${name}() {
          local cur prev subcmd
          cur="''${COMP_WORDS[COMP_CWORD]}"
          prev="''${COMP_WORDS[COMP_CWORD-1]}"
          subcmd=""

          local i
          for (( i=1; i < COMP_CWORD; i++ )); do
            if [[ "''${COMP_WORDS[i]}" != -* ]]; then
              subcmd="''${COMP_WORDS[i]}"
              break
            fi
          done

          case "''${subcmd}" in
          ${completionCases}
          *)
            if [[ "''${cur}" == -* ]]; then
              COMPREPLY=(''$(compgen -W "-h --help -v --version" -- "''${cur}"))
            else
              COMPREPLY=(''$(compgen -W "${subcmdNames}" -- "''${cur}"))
            fi
            ;;
          esac
        }

        complete -F _${name} ${name}
      '';
    };
in
symlinkJoin {
  inherit name;
  paths = [
    script
    bash-completion
  ];
}

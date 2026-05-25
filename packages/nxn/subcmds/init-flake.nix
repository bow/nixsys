{
  lib,
}:
let
  name = "init-flake";

  description = "Initialize a flake setup from https://github.com/bow/flates";

  varName = lib.replaceStrings [ "-" ] [ "_" ] name;

  cmdFuncName = "cmd_${varName}";

  usageFuncName = "usage_${varName}";
in
{
  inherit name description cmdFuncName;

  body = ''
    ${usageFuncName}() {
      cat <<EOF
    Usage: ''${CMD} ${name} <template-name>

    ${description}

    Arguments:
      <template-name>       Flake template to use.

    Examples:
      ''${CMD} ${name} python-pkg
      ''${CMD} ${name} rust
    EOF
    }

    ${cmdFuncName}() {
      local input=""

      while [[ $# -gt 0 ]]; do
        case "''$1" in
        -h | --help)
          ${usageFuncName}
          exit 0
          ;;
        --)
          shift
          input="''${1:-}"
          break
          ;;
        -*)
          echo "''${CMD} ${name}: error: unknown option: ''$1" >&2
          ${usageFuncName} >&2
          exit 1
          ;;
        *)
          if [[ ! -z "''${input}" ]]; then
            echo "''${CMD} ${name}: error: unexpected argument: ''$1" >&2
            ${usageFuncName} >&2
            exit 1
          fi
          input="''$1"
          shift
          ;;
        esac
      done

      if [[ -z "''${input}" ]]; then
        echo "''${CMD} ${name}: error: required <template-name> is missing" >&2
        ${usageFuncName} >&2
        exit 1
      fi

      nix flake init -t github:bow/flates#''${input}
    }
  '';

  completion = ''
    ${name})
      ;;
  '';
}

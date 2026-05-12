{
  lib,
  coreutils,
  which,
  util-linux,
  gnused,
  graphviz,
  timg,
}:
let
  name = "show-deps";

  description = "Show the dependecies of an executable or a Nix store package in graph";

  varName = lib.replaceStrings [ "-" ] [ "_" ] name;

  cmdFuncName = "cmd_${varName}";

  usageFuncName = "usage_${varName}";

  ##

  fgColor = "#427b58";
  bgColor = "#f9f5d7";
  maxGraphNodes = "100";
in
{
  inherit name description cmdFuncName;

  body = ''
    ${usageFuncName}() {
      cat <<EOF
    Usage: ''${CMD} ${name} [OPTIONS] <name-or-path>

    ${description}

    Arguments:
      <name-or-store-path>  An executable name in PATH, a file path, or an absolute /nix/store/... path.

    Options:
      -f, --force           Ignore the node limit (${maxGraphNodes}) and render regardless of graph size.
      -h, --help            Show this help message and exit.

    Examples:
      ''${CMD} ${name} git
      ''${CMD} ${name} ${coreutils}
      ''${CMD} ${name} ./result/bin/tool
      ''${CMD} ${name} --force firefox
    EOF
    }

    ${cmdFuncName}() {
      local force=0
      local input=""

      while [[ $# -gt 0 ]]; do
        case "''$1" in
        -h | --help)
          ${usageFuncName}
          exit 0
          ;;
        -f | --force)
          force=1
          shift
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
        echo "''${CMD} ${name}: error: required <name-or-store-path> is missing" >&2
        ${usageFuncName} >&2
        exit 1
      fi

      if [[ $# -gt 1 ]]; then
        echo "''${CMD} ${name}: error: unexpected argument: ''$1" >&2
        ${usageFuncName} >&2
        exit 1
      fi

      local path
      if [[ "''${input}" == /nix/store/* ]] && [[ -e "''${input}" ]]; then
        path="''${input}"
      elif [[ -e "''${input}" ]]; then
        path=''$(${coreutils}/bin/readlink -f "''${input}")
      else
        local which_path
        which_path=''$(${which}/bin/which "''${input}") || {
          echo "''${CMD} ${name}: error: ''${input} not found in PATH" >&2
          exit 1
        }
        path=''$(${coreutils}/bin/readlink -f "''${which_path}")
      fi

      local graph
      graph=''$(nix-store --query --graph "''${path}")

      if (( !force )); then
        local line_count
        line_count=''$(printf '%s\n' "''${graph}" | ${coreutils}/bin/wc -l)
        node_count=$((line_count - 2))
        if (( node_count > ${maxGraphNodes} )); then
          echo "''${CMD} ${name}: error: graph has ''${node_count} nodes (limit: ${maxGraphNodes}). Use -f/--force to render anyway." >&2
          exit 1
        fi
      fi

      printf '%s\n' "''${graph}" \
        | ${gnused}/bin/sed 's/fillcolor = "#ff0000"/color = "${fgColor}", fillcolor = "${fgColor}", fontcolor = "${bgColor}"/g' \
        | ${gnused}/bin/sed 's/ \[color = "[^"]*"\]/ \[color = "${fgColor}"\]/g' \
        | ${graphviz}/bin/dot -Tpng \
        | ${timg}/bin/timg -
    }
  '';

  completion = ''
    ${name})
      if [[ "''${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W '-f --force -h --help' -- "''${cur}") )
      elif [[ "''${cur}" == /nix/store* || "''${cur}" == /* || "''${cur}" == ./* || "''${cur}" == ../* ]]; then
        compopt -o filenames 2>/dev/null
        COMPREPLY=( $(compgen -f -- "''${cur}") )
      else
        COMPREPLY=( $(compgen -c -- "''${cur}") )
      fi
      ;;
  '';
}

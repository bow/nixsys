{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  libcfg = lib.nixsys.home;

  batEnabled = libcfg.isBatEnabled config;
  dockerEnabled = libcfg.isDockerEnabled config;
  fzfEnabled = libcfg.isFzfEnabled config;
  fzfPackage = libcfg.getFzfPackage config;
  gpgEnabled = libcfg.isGpgEnabled config;
  gpgPackage = libcfg.getGpgPackage config;
  neovimEnabled = libcfg.isNeovimEnabled config;
  neovimPackage = libcfg.getNeovimPackage config;
  ripgrepEnabled = libcfg.isRipgrepEnabled config;
  ripgrepPackage = libcfg.getRipgrepPackage config;
  shellBash = libcfg.isShellBash user;
  xorgEnabled = libcfg.isXorgEnabled config;
  zoxideEnabled = libcfg.isZoxideEnabled config;
in
{
  config = lib.mkIf shellBash {

    programs.bash = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      historyControl = [
        "ignoredups"
        "ignorespace"
        "erasedups"
      ];
      historyFileSize = 200000;
      historyIgnore = [
        "eza"
        "ls"
        "pwd"
        "tree"
        "zt"
      ];
      historySize = 100000;
      shellOptions = [
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
        "checkjobs"
      ];

      sessionVariables = {
        PAGER = "less";
        LESS = "-F -X -g -S -w -z-2 -#.1 -M -R";
        EDITOR = if neovimEnabled then "nvim" else "vi";
      }
      // lib.optionalAttrs zoxideEnabled { _ZO_ECHO = 1; };

      shellAliases = {
        # chmod +x.
        chmox = "${pkgs.coreutils}/bin/chmod +x";
        # cp, interactive, verbose.
        cp = "cp -iv";
        # df, with total size, with human-readable output.
        df = "${pkgs.coreutils}/bin/df -h -T --total";
        # du, with human-readable output.
        du = "${pkgs.coreutils}/bin/du -sh";
        # grep, colorized.
        grep = "grep --color=auto";
        # less, without wrapping, with line numbers.
        less = "${pkgs.less}/bin/less -SN";
        # ls, colorized.
        ls = "${pkgs.coreutils}/bin/ls -F --color=auto";
        # ls, sorted by name.
        lname = "${pkgs.coreutils}/bin/ls -alF";
        # ls, sorted by size.
        lsize = "${pkgs.coreutils}/bin/ls -lSrh";
        # ls, sorted by mtime.
        ltime = "${pkgs.coreutils}/bin/ls -ltrh";
        # mkdir, create parents.
        mkdir = "mkdir -p";
        # mv, interactive.
        mv = "mv -i";
        # rm, interactive.
        rm = "rm -i";
        # terraform.
        tf = "${pkgs.terraform}/bin/terraform";
        # eza.
        z = "${pkgs.eza}/bin/eza";
        # eza list view.
        zl = "${pkgs.eza}/bin/eza --long --header --binary --git --sort=name --group-directories-first -g -M -o --no-permissions -aa";
        # eza tree view.
        zt = "${pkgs.eza}/bin/eza --long --header --binary --git --sort=name --group-directories-first -g -M -o --no-permissions --tree --level 2";

        # grep history.
        grest = "history | ${pkgs.gnugrep}/bin/grep";
      }
      // lib.optionalAttrs xorgEnabled {
        clip = "${pkgs.findutils}/bin/xargs ${pkgs.coreutils}/bin/echo -n | ${pkgs.xclip}/bin/xclip -selection c";
      }
      // lib.optionalAttrs dockerEnabled {
        # List container processes.
        dps = "${pkgs.docker}/bin/docker ps";
        # List container processes including stopped containers.
        dpsa = "${pkgs.docker}/bin/docker ps -a";
        # List images.
        dlsi = "${pkgs.docker}/bin/docker images";
        # List volumes.
        dlsv = "${pkgs.docker}/bin/docker volume ls";
        # List networks.
        dlsn = "${pkgs.docker}/bin/docker network ls";
        # Run daemonized container, e.g., drnd base /bin/echo hello.
        drnd = "${pkgs.docker}/bin/docker run -dP";
        # Run interactive container, e.g. drni base /bin/bash.
        drni = "${pkgs.docker}/bin/docker run --rm -itP";
      };

      profileExtra = ''
        # Load private and local settings if it exists.
        # shellcheck disable=SC1091
        [[ -f ~/.profile_private ]] && . "''${HOME}/.profile_private"
        [[ -f ~/.profile_local ]] && . "''${HOME}/.profile_local"
      '';

      bashrcExtra = ''
        # Fallback for plain console.
        if [[ "$TERM" == "linux" ]]; then
            ${pkgs.coreutils}/bin/echo -en "\e]P0111111" # black
            ${pkgs.coreutils}/bin/echo -en "\e]P8111111" # darkgrey
            ${pkgs.coreutils}/bin/echo -en "\e]P1803232" # darkred
            ${pkgs.coreutils}/bin/echo -en "\e]P9c43232" # red
            ${pkgs.coreutils}/bin/echo -en "\e]P23d762f" # darkgreen
            ${pkgs.coreutils}/bin/echo -en "\e]PA5ab23a" # green
            ${pkgs.coreutils}/bin/echo -en "\e]P3aa9943" # brown
            ${pkgs.coreutils}/bin/echo -en "\e]PBefef60" # yellow
            ${pkgs.coreutils}/bin/echo -en "\e]P427528e" # darkblue
            ${pkgs.coreutils}/bin/echo -en "\e]PC4388e1" # blue
            ${pkgs.coreutils}/bin/echo -en "\e]P5706c9a" # darkmagenta
            ${pkgs.coreutils}/bin/echo -en "\e]PDa07de7" # magenta
            ${pkgs.coreutils}/bin/echo -en "\e]P65da5a5" # darkcyan
            ${pkgs.coreutils}/bin/echo -en "\e]PE98e1e1" # cyan
            ${pkgs.coreutils}/bin/echo -en "\e]P7d0d0d0" # lightgrey
            ${pkgs.coreutils}/bin/echo -en "\e]PFffffff" # white
            clear                  # for background artifacting

            # shellcheck disable=SC2034
            nocol='\033[0m'
            # shellcheck disable=SC2034
            red='\033[31m'
            # shellcheck disable=SC2034
            green='\033[32m'
            # shellcheck disable=SC2034
            yellow='\033[33m'
            # shellcheck disable=SC2034
            blue='\033[34m'
            # shellcheck disable=SC2034
            purple='\033[35m'
            # shellcheck disable=SC2034
            cyan='\033[36m'
            # shellcheck disable=SC2034
            grey='\033[37m'

            . "${pkgs.git}/share/git/contrib/completion/git-prompt.sh"
            function get_git_stat {
                export GIT_PS1_SHOWSTASHSTATE=true
                export GIT_PS1_SHOWDIRTYSTATE=true
                export GIT_PS1_SHOWUNTRACKEDFILES=true
                export GIT_PS1_SHOWUPSTREAM="verbose"
                nick=''$(__git_ps1 "(  %s) ")
                [[ -n "''$nick" ]] && ${pkgs.coreutils}/bin/echo "''$nick"
                return 0
            }

            function set_prompt {
                PS1="\n''${nocol}\`if [[ \''$? -eq 0 ]]; then ${pkgs.coreutils}/bin/echo ''${blue}; else ${pkgs.coreutils}/bin/echo ''${red}; fi\`-\[''${nocol}\] \[''${blue}\]\u@\h\[''${nocol}\] ''$(get_git_stat)\[''${nocol}\]\[''${yellow}\]\w\[''${nocol}\]\n> "
            }
            PROMPT_COMMAND=set_prompt
        else
            export TERM=xterm-256color
        fi

        # Pack directories.
        function pack() {
            target=''${2%/}
            case ''${1} in
                gz)
                    ${pkgs.gnutar}/bin/tar czvf "''${target}.tar.gz" "''${target}" ;;
                bz)
                    ${pkgs.gnutar}/bin/tar cjvf "''${target}.tar.bz2" "''${target}" ;;
                xz)
                    ${pkgs.gnutar}/bin/tar cJvf "''${target}.tar.xz" "''${target}" ;;
                7z)
                    ${pkgs.p7zip}/bin/7zr a "''${target}.7z" "''${target}" ;;
                rar)
                    ${pkgs.rar}/bin/rar a "''${target}.rar" "''${target}" ;;
                zip)
                    ${pkgs.zip}/bin/zip -r "''${target}.zip" "''${target}" ;;
                zst | zstd)
                    ${pkgs.gnutar}/bin/tar --zstd -cvf "''${target}.tar.zst" "''${target}" ;;
                *)
                    ${pkgs.coreutils}/bin/echo "Usage: pack [gzip|bzip2|xz|7z|rar|zip|zst] [target]" ;;
            esac
        }

        # Unpack directories.
        function unpack() {
            case ''${1} in
                *.tar.gz | *.tgz | *.tar.bz2 | *.tbz2 | *.tar.xz | *.txz | *.tar.zst | *.tzst | *.tar.zstd | *.tzstd | *.tar)
                    ${pkgs.gnutar}/bin/tar xfv "''${1}" ;;
                *.gem)
                    ${pkgs.gnutar}/bin/tar xfv "''${1}" ;;
                *.7z)
                    ${pkgs.p7zip}/bin/7zr x "''${1}" ;;
                *.rar)
                    ${pkgs.rar}/bin/unrar x "''${1}" ;;
                *.xz)
                    ${pkgs.xz}/bin/unxz "''${1}" ;;
                *.zip)
                    ${pkgs.zip}/bin/unzip "''${1}" ;;
                *.zst | *.zstd)
                    ${pkgs.zstd}/bin/zst -d "''${1}" ;;
                *)
                    ${pkgs.coreutils}/bin/echo "Usage: unpack [target]" ;;
            esac
        }

        # Create dir and cd into it.
        # shellcheck disable=SC2164
        function mkcd() { ${pkgs.coreutils}/bin/mkdir -p "''${1}" && cd "''${1}"; }

        # cd into the directory in which a file is contained.
        function fcd() { cd "''$(dirname "''${1}")" || exit 1; }

        # Change owner to current user.
        function mkmine() { sudo ${pkgs.coreutils}/bin/chown -R "''${USER}" "''${1:-.}"; }

        # Open an ssh connection and run tmux.
        function sshx() {
            ${pkgs.openssh}/bin/ssh "''${1}" -t -- /bin/sh -c 'tmux has-session && exec tmux attach || exec tmux'
        }

        # Set file open handler.
        function open() { ${pkgs.handlr-regex}/bin/handlr open "''${1:-.}"; }

        # Calculator.
        function calc() { ${pkgs.coreutils}/bin/echo "''$*" | ${pkgs.bc}/bin/bc; }

        # Show the absolute path of a command executable.
        # shellcheck disable=SC2164
        function wx() { ${pkgs.coreutils}/bin/readlink -f "''$(${pkgs.which}/bin/which "''${1}")"; }

        # Get absolute path to python module.
        function wpymod() {
            local modname="''${1}"
            # NOTE: Intended to resolve dynamically, so no Nix store.
            python <<EOF || false
        import sys
        try:
            import ''${modname}
        except ImportError:
            print("Error: module ''${1} not found")
            sys.exit(1)
        print(''${modname}.__file__)
        EOF
        }

        # .local/bin config
        case ":''${PATH}:" in
            *:"''${HOME}/.local/bin":*)
                ;;
            *)
                export PATH="''${HOME}/.local/bin:''${PATH}"
                ;;
        esac

        # Load private and local settings if it exists.
        # shellcheck disable=SC1091
        [[ -f ~/.bash_private ]] && . "''${HOME}/.bash_private"
        [[ -f ~/.bash_local ]] && . "''${HOME}/.bash_local"
      ''
      + lib.optionalString gpgEnabled ''

        # Reset GPG and SSH agents.
        function credsreset() {
            ${gpgPackage}/bin/gpgconf --kill gpg-agent && eval "''$(${pkgs.openssh}/bin/ssh-agent -s)" && . "''${HOME}/.profile"
        }
      ''
      + lib.optionalString (user.location.city != "") ''

        # Check weather from wttr.
        function wttr() { ${pkgs.curl}/bin/curl http://wttr.in/"''${1:-${user.location.city}}"; }
      ''
      + lib.optionalString neovimEnabled ''

        # Open a file, creating all the necessary parents.
        function nvimk() { command mkdir -p "''$(dirname "''${1}")" && ${neovimPackage}/bin/nvim "''$1"; }
      ''
      + lib.optionalString xorgEnabled ''

        # Resolve path and copy it to clipboard.
        function pcp() {
            target=''$(${pkgs.coreutils}/bin/readlink -f "''${1:-.}")
            ${pkgs.coreutils}/bin/echo -n "''${target}" | ${pkgs.xclip}/bin/xclip -selection c && ${pkgs.coreutils}/bin/echo "''${target}"
        }

        # cat file and copy it to clipboard.
        function pcat() {
            if [ ''$# -ne 1 ]; then
                ${pkgs.coreutils}/bin/echo "Usage: pcat [FILE]" >&2
                return 1
            fi
            if [[ -f "''${1}" ]]; then
                if [[ ''$(${pkgs.coreutils}/bin/stat -c%s "''${1}") -ge 1048576 ]]; then
                    ${pkgs.coreutils}/bin/echo "Error: ''${1} exceeds maximum allowed size of 1 MiB"
                    return 1
                else
                    ${pkgs.coreutils}/bin/tee >(${pkgs.findutils}/bin/xargs ${pkgs.coreutils}/bin/echo -n | ${pkgs.xclip}/bin/xclip -selection c) < "''${1}"
                fi
            else
                ${pkgs.coreutils}/bin/echo "Error: ''${1} not found"
                return 1
            fi
        }
      ''
      + lib.optionalString batEnabled ''

        # Show help with colors.
        function help() {
            "''$@" --help 2>&1 | ${pkgs.bat}/bin/bat --plain --language=help
        }
      ''
      + lib.optionalString (batEnabled && ripgrepEnabled && fzfEnabled) ''

        # Interactive text search and edit.
        function frg() {
            result=''$(
                ${ripgrepPackage}/bin/rg --ignore-case --color=always --line-number --no-heading "''$@" \
                | ${fzfPackage}/bin/fzf \
                    --ansi --color 'hl:-1:underline,hl+:-1:underline:reverse' \
                    --delimiter ':' \
                    --preview "${pkgs.bat}/bin/bat --color=always {1} --theme='gruvbox-dark' --highlight-line {2}" \
                    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
            )
            file="''${result%%:*}"
            linenumber=''$(${pkgs.coreutils}/bin/echo "''${result}" | ${pkgs.coreutils}/bin/cut -d: -f2)
            if [[ -n "''${file}" ]]; then
                ''${EDITOR} +"''${linenumber}" "''${file}"
            fi
        }
      ''
      + lib.optionalString dockerEnabled ''

        alias dc='docker-compose'

        # Execute interactive container, e.g. dexi base /bin/bash
        function dexi() { ${pkgs.docker}/bin/docker exec -it "''${1}" "''${2:-/bin/bash}"; }

        # Remove exited containers.
        # shellcheck disable=SC2046
        function drm() { ${pkgs.docker}/bin/docker rm ''$(${pkgs.docker}/bin/docker ps -qf 'status=exited'); }

        # Remove dangling images.
        # shellcheck disable=SC2046
        function drmi() { ${pkgs.docker}/bin/docker rmi ''$(${pkgs.docker}/bin/docker images -qf 'dangling=true'); }

        # Shell into running container.
        function dsh() { ${pkgs.docker}/bin/docker exec -it "''$(${pkgs.docker}/bin/docker ps -aqf 'name=''${1}')" "''${2:-sh}"; }

        # Dockerfile build, e.g. dbu tcnksm/test.
        function dbu() { ${pkgs.docker}/bin/docker build -t="''$1" .; }
      '';
    };
  };
}

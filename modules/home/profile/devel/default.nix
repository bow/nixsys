{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  inherit (lib.nixsys) enabled enabledWith;
  libcfg = lib.nixsys.home;

  shellBash = libcfg.isShellBash user;

  mkDevelModuleImports = lib.mapAttrsToList (name: args: mkDevelModule ({ inherit name; } // args));

  mkDevelModule =
    {
      name,
      langservers ? [ ],
      tools ? [ ],
      extraOptions ? { },
      extraConfig ? { },
    }:
    let
      inherit (lib) types;
      dcfg = config.nixsys.home.profile.devel.${name};
    in
    {
      options.nixsys.home.profile.devel.${name} = lib.recursiveUpdate {
        enable = lib.mkEnableOption "nixsys.home.profile.devel.${name}" // {
          default = config.nixsys.home.profile.devel.enable;
        };
        langservers = lib.mkOption {
          type = types.listOf types.package;
          default = langservers;
        };
        tools = lib.mkOption {
          type = types.listOf types.package;
          default = tools;
        };
      } extraOptions;

      config = lib.mkIf dcfg.enable (
        lib.recursiveUpdate {
          home.packages = dcfg.tools;
          programs.neovim.extraPackages = dcfg.langservers ++ dcfg.tools;
        } extraConfig
      );
    };

  cfg = config.nixsys.home.profile.devel;
in
{
  options.nixsys.home.profile.devel = {
    enable = lib.mkEnableOption "nixsys.home.profile.devel";
  };

  imports = mkDevelModuleImports {

    asciidoc = {
      tools = [
        pkgs.unstable.asciidoctor-with-extensions
      ];
    };

    bazel = {
      tools = [
        pkgs.unstable.bazel
        pkgs.unstable.starlark-rust
      ];
    };

    c = {
      langservers = [
        pkgs.unstable.ccls
      ];
      tools = [
        # See: https://github.com/nix-community/home-manager/issues/1668#issuecomment-1264298055
        (lib.meta.hiPrio pkgs.unstable.gcc)
        pkgs.unstable.clang_21
        pkgs.unstable.clang-tools
        pkgs.unstable.cmake
        pkgs.unstable.gdb
        pkgs.unstable.lld
        pkgs.unstable.lldb
        pkgs.unstable.valgrind
      ];
      extraConfig = {
        home.file.".clang-format".text = ''
          BasedOnStyle: LLVM

          AlignAfterOpenBracket: BlockIndent
          AllowAllParametersOfDeclarationOnNextLine: false
          AllowShortFunctionsOnASingleLine: Empty
          AllowShortLambdasOnASingleLine: Empty
          AlwaysBreakBeforeMultilineStrings: true
          BinPackArguments: false
          BinPackParameters: false
          BreakBeforeBinaryOperators: NonAssignment
          BreakBeforeBraces: Attach
          # TODO: Enable after clang 20 release.
          # BreakBinaryOperations: OnePerLine
          ColumnLimit: 112
          ExperimentalAutoDetectBinPacking: false
          IncludeCategories:
            - Regex:    '^<.*\.h'
              Priority: 1
            - Regex:    '^".*\.h"'
              Priority: 2
          IndentCaseLabels: true
          IndentWidth: 4
          LineEnding: LF
          PointerAlignment: Left
          SortIncludes: CaseSensitive
        '';
      };
    };

    css = {
      langservers = [
        pkgs.vscode-langservers-extracted
      ];
    };

    elixir = {
      extraConfig = {
        home.file.".iex.exs".text = ''
          IEx.configure(
            colors: [
              syntax_colors: [
                number: :light_yellow,
                atom: :light_cyan,
                string: :light_black,
                boolean: :red,
                nil: [:magenta, :bright],
              ],
              ls_directory: :cyan,
              ls_device: :yellow,
              doc_code: :green,
              doc_inline_code: :magenta,
              doc_headings: [:cyan, :underline],
              doc_title: [:cyan, :bright, :underline],
            ],
            default_prompt:
              "#{IO.ANSI.magenta}%prefix#{IO.ANSI.reset} " <>
              "[#{IO.ANSI.light_black}%counter#{IO.ANSI.reset}]>",
            alive_prompt:
              "#{IO.ANSI.magenta}%prefix#{IO.ANSI.reset} " <>
              "(#{IO.ANSI.cyan}%node#{IO.ANSI.reset}) " <>
              "[#{IO.ANSI.light_black}%counter#{IO.ANSI.reset}]>",
            history_size: 50,
            inspect: [
              pretty: true,
              limit: :infinity,
              width: 80,
              # charlists: :as_lists
            ],
            width: 80
          )
        '';
      };
    };

    go = {
      langservers = [
        pkgs.unstable.gopls
      ];
      tools = [
        pkgs.unstable.delve
        pkgs.unstable.go
        pkgs.unstable.gofumpt
      ];
      extraConfig = lib.optionalAttrs shellBash {
        programs.bash.bashrcExtra = with config.home; ''
          # Go config.
          export GOPATH="${homeDirectory}/.local/go"
          case ":''${PATH}:" in
              *:"${homeDirectory}/.local/go/bin":*)
                  ;;
              *)
                  export PATH="${homeDirectory}/.local/go/bin:''${PATH}"
                  ;;
          esac
        '';
      };
    };

    graphviz = {
      langservers = [
        pkgs.unstable.dot-language-server
      ];
      tools = [
        pkgs.graphviz
      ];
    };

    haskell = {
      langservers = [
        pkgs.unstable.haskell-language-server
      ];
    };

    terraform = {
      tools = [
        pkgs.unstable.terraform
      ];
      langservers = [
        pkgs.unstable.terraform-ls
        pkgs.unstable.terraform-lsp
      ];
    };

    java = {
      langservers = [
        pkgs.unstable.jdt-language-server
      ];
    };

    javascript = {
      tools = [
        pkgs.unstable.nodejs
      ];
    };

    just = {
      tools = [
        pkgs.unstable.just
      ];
    };

    lua = {
      langservers = [
        pkgs.unstable.lua-language-server
      ];
      tools = [
        pkgs.unstable.stylua
      ];
    };

    latex = {
      langservers = [
        pkgs.unstable.texlab
      ];
      tools = [
        pkgs.unstable.texliveFull
      ];
    };

    nix = {
      langservers = [
        pkgs.unstable.nil
      ];
      tools = [
        pkgs.unstable.deadnix
        pkgs.unstable.nixfmt-rfc-style
        pkgs.unstable.statix
      ];
    };

    ocaml = {
      extraConfig = {
        home.file.".ocamlinit".text = ''
          (* Added by OPAM. *)
            try Topdirs.dir_directory (Sys.getenv "OCAML_TOPLEVEL_PATH")
            with Not_found -> ()
          ;;

          Sys.interactive := false;;
          #use "topfind";;
          #require "base";;
          Sys.interactive := true;;
        '';
      };
    };

    perl = {
      langservers = [
        pkgs.unstable.perlnavigator
      ];
    };

    postgresql = {
      langservers = [
        pkgs.unstable.postgres-language-server
      ];
      tools = [
        pkgs.unstable.postgresql
        # FIXME: Revert back to unstable when it works again.
        pkgs.sqlfluff
      ];
      extraConfig = {
        home.file.".psqlrc".text = ''
          \set QUIET 1

          -- Configure data and table displays
          \pset null '⬥'
          \pset linestyle unicode
          \pset border 2

          -- Customize prompts
          \set PROMPT1 '\n%[%033[36m%]● %033[35m%]%n@%M:%> %033[37m%]via %`hostname -f` %[%033[33m%]%/ %[%033[32m%][%R]\n%[%033[36m%]%#%[%033[0m%]% '
          \set PROMPT2 '%[%033[36m%]%R%[%033[0m%] '

          -- Show how long each query takes to execute
          \timing

          -- Use best available output format
          \x auto
          \set VERBOSITY verbose
          \set HISTFILE ~/.psql_history- :DBNAME
          \set HISTCONTROL ignoredups
          \set HISTSIZE 2000
          \set COMP_KEYWORD_CASE preserve-upper
          \set ON_ERROR_ROLLBACK interactive

          -- Store commands

          \set long_running 'SELECT pid, now() - pg_stat_activity.xact_start AS duration, query, state FROM pg_stat_activity WHERE (now() - pg_stat_activity.xact_start) > interval \'\'5 minutes\'\' ORDER by 2 DESC;'

          \set cache_hit 'SELECT \'\'index hit rate\'\' AS name, (sum(idx_blks_hit)) / nullif(sum(idx_blks_hit + idx_blks_read),0) AS ratio FROM pg_statio_user_indexes UNION ALL SELECT \'\'table hit rate\'\' AS name, sum(heap_blks_hit) / nullif(sum(heap_blks_hit) + sum(heap_blks_read),0) AS ratio FROM pg_statio_user_tables;'

          \set unused_indexes 'SELECT schemaname AS schema, relname AS table, indexrelname AS index, pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size, idx_scan as index_scans FROM pg_stat_user_indexes ui JOIN pg_index i ON ui.indexrelid = i.indexrelid WHERE NOT indisunique AND idx_scan < 50 AND pg_relation_size(relid) > 5 * 8192 ORDER BY pg_relation_size(i.indexrelid) / nullif(idx_scan, 0) DESC NULLS FIRST, pg_relation_size(i.indexrelid) DESC;'

          \set table_sizes 'SELECT n.nspname AS schema, c.relname AS table, pg_size_pretty(pg_table_size(c.oid)) AS size FROM pg_class c LEFT JOIN pg_namespace n ON (n.oid = c.relnamespace) WHERE n.nspname NOT IN (\'\'pg_catalog\'\', \'\'information_schema\'\') AND n.nspname !~ \'\'^pg_toast\'\' AND c.relkind=\'\'r\'\' ORDER BY pg_table_size(c.oid) DESC;'

          \unset QUIET
        '';
      };
    };

    protobuff = {
      tools = [
        pkgs.unstable.buf
      ];
    };

    python = {
      langservers = [
        pkgs.unstable.python313Packages.pyls-isort
        pkgs.unstable.python313Packages.python-lsp-server
      ];
      tools = [
        pkgs.unstable.basedpyright
        pkgs.unstable.mypy
        pkgs.unstable.poetry
        pkgs.unstable.pyrefly
        pkgs.unstable.python3
        pkgs.unstable.ruff
      ];
      extraConfig = {
        programs.uv = {
          enable = true;
          package = pkgs.unstable.uv;
        };
        programs.bash = lib.mkIf shellBash rec {
          sessionVariables = {
            PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/python/pycache";
          };
          bashrcExtra = ''
            mkdir -p ${sessionVariables.PYTHONPYCACHEPREFIX}
          '';
        };
      };
    };

    r = {
      extraConfig = {
        home.file.".Rprofile".text = ''
          # set width
          options("width" = 160)
          # set tab width
          options("tab width" = 2)
          # show sub-second time stamps
          options("digits.secs" = 3)
          options(repos = r)
          # set prompt
          options(prompt = "> ", digits = 4, show.signif.stars = FALSE)

          # load useful packages in the beginning
          .First <- function() {
              suppressWarnings(suppressMessages(require(R.utils, quietly = TRUE)))
          }

          # define handy functions
          peek <- function(obj) {
              # Shows useful quick information about an object
              #
              # Args:
              #   obj: R object to investigate

              message("class : ", class(obj))
              message("typeof: ", typeof(obj))
              message("length: ", length(obj))
              message("rows  : ", nrow(obj))
              message("cols  : ", ncol(obj))
          }

          message(R.version.string)
        '';
      };
    };

    ruby = {
      langservers = [
        pkgs.unstable.ruby-lsp
      ];
    };

    rust = {
      tools = [
        pkgs.unstable.rustup
      ];
      extraConfig = lib.optionalAttrs shellBash {
        programs.bash.bashrcExtra = with config.home; ''
          # Cargo config.
          case ":''${PATH}:" in
              *:"${homeDirectory}/.cargo/bin":*)
                  ;;
              *)
                  export PATH="${homeDirectory}/.cargo/bin:''${PATH}"
                  ;;
          esac
        '';
      };
    };

    sh = {
      langservers = [
        pkgs.unstable.bash-language-server
      ];
      tools = [
        pkgs.unstable.shfmt
      ];
    };

    sqlite = {
      tools = [
        # FIXME: Revert back to unstable when it works again.
        pkgs.sqlfluff
      ];
      extraConfig = {
        home.file.".sqliterc".text = ''
          .header ON
          .mode column
          .nullvalue "⬥"
          .width 0
          .prompt 'sqlite> ' '...   - '
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.unstable.cloc
      pkgs.unstable.curlie
      pkgs.unstable.dos2unix
      pkgs.unstable.entr
      pkgs.unstable.glow
      pkgs.unstable.gnumake
      pkgs.unstable.gnupatch
      pkgs.unstable.grpcurl
      pkgs.unstable.minify
      pkgs.unstable.wrk
      pkgs.unstable.xan
    ];

    nixsys.home.programs = {
      bat = enabled;
      direnv = enabled;
      git = enabled;
      neovim = enabledWith { extended = true; };
      starship = enabled;
      tmux = enabled;

      # Navigation.
      yazi = enabled;
      zoxide = enabled;

      # Virtualization.
      distrobox = enabled;
      nerdctl = enabled;
      packer = enabled;
      virt-viewer = enabled;
    };
  };
}

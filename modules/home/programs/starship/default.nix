{
  config,
  lib,
  user,
  ...
}:
let
  libcfg = lib.nixsys.home;

  shellBash = libcfg.isShellBash user;

  cfg = config.nixsys.home.programs.starship;
in
{
  options.nixsys.home.programs.starship = {
    enable = lib.mkEnableOption "nixsys.home.programs.starship";
  };

  config = lib.mkIf cfg.enable rec {
    programs.starship = {
      enable = true;
      enableBashIntegration = shellBash;

      settings = {
        format = lib.concatStrings [
          "$nix_shell$custom "
          "$username$hostname$sudo "
          "$shlvl"
          "$git_branch$git_commit$git_status"
          "$python"
          "$rust"
          "$golang"
          "$lua"
          "$ruby"
          "$kotlin"
          "$java"
          "$nodejs"
          "$c"
          "$directory"
          "$line_break"
          "$shell"
          "$character"
        ];
        add_newline = true;

        character = {
          success_symbol = "[▶](green)";
          error_symbol = "[▶](red)";
        };

        c = {
          format = "[·](dimmed white) [[c](cyan)[/](white)($version)](purple) ";
        };

        custom.non_nix_mark = {
          format = "[($output)](bright-black)";
          command = ''printf "%s" "▬"'';
          when = ''test -z "$IN_NIX_SHELL"'';
        };

        directory = {
          format = "[·](dimmed white) [$read_only]($read_only_style)[$path]($style) ";
          style = "yellow";
          truncation_length = 100;
          truncate_to_repo = false;
        };

        git_branch = {
          format = "[·](dimmed white) [$branch]($style) ";
          always_show_remote = true;
          style = "bright-black";
        };

        git_commit = {
          format = ''[\($hash\)](bright-black)[$tag](bold bright-black) '';
          disabled = false;
          only_detached = false;
          tag_disabled = false;
          tag_symbol = " 🏷 ";
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "bright-black";
          ahead = ''⇡''${count}'';
          diverged = ''⇕⇡''${ahead_count}⇣''${behind_count}'';
          behind = ''⇣''${count}'';
          staged = ''+''${count}'';
          modified = "*";
        };

        golang = {
          format = "[·](dimmed white) [[go](cyan)[/](white)($version)](purple) ";
          version_format = ''''${major}.''${minor}'';
        };

        hostname = {
          format = "[@$hostname]($style)";
          style = "#007c5b";
          ssh_only = false;
          trim_at = "";
        };

        java = {
          format = "[·](dimmed white) [[java](cyan)[/](white)($version)](purple) ";
          version_format = ''''${raw}'';
        };

        kotlin = {
          format = "[·](dimmed white) [[kt](cyan)[/](white)($version)](purple) ";
          version_format = ''''${raw}'';
        };

        lua = {
          format = "[·](dimmed white) [[lua](cyan)[/](white)($version)](purple) ";
          detect_folders = [ ];
        };

        nix_shell = {
          disabled = false;
          format = "[$state](white)";
          impure_msg = "[✲](bold yellow)";
          pure_msg = "[●](bold bright-blue)";
          unknown_msg = "[?](bold bright-black)";
        };

        nodejs = {
          format = "[·](dimmed white) [[js](cyan)[/](white)($version)](purple) ";
        };

        python = {
          format = "[·](dimmed white) [[py](cyan)[/](white)($virtualenv:$version)](purple) ";
        };

        ruby = {
          format = "[·](dimmed white) [[rb](cyan)[/](white)($version)](purple) ";
        };

        rust = {
          format = "[·](dimmed white) [[rs](cyan)[/](white)($version)](purple) ";
        };

        shlvl = {
          disabled = false;
          format = "[·](dimmed white)[$symbol](dimmed white)";
          repeat = true;
          symbol = "/";
          repeat_offset = 3;
        };

        sudo = {
          format = "[$symbol]($style)";
          symbol = "⊹";
          style = "#ff7f50";
          disabled = false;
        };

        username = {
          style_user = "#007c5b";
          style_root = "red";
          show_always = true;
          format = "[$user]($style)";
        };
      };
    };

    programs.bash.initExtra = lib.mkIf programs.starship.enableBashIntegration ''
      function set_window_title() {
          # shellcheck disable=SC2116
          echo -ne "\033]0; $(echo "Terminal ''${PWD/#$HOME/'~'}") \007"
      }
      # shellcheck disable=SC2034
      starship_precmd_user_func="set_window_title"
    '';
  };
}

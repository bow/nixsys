{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.home.services.mpd;
in
{
  options.nixsys.home.services.mpd = {
    enable = lib.mkEnableOption "nixsys.home.services.mpd";
    package = lib.mkPackageOption pkgs "mpd" { };

    db-file = lib.mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/mpd/mpd.db";
    };

    fifo-file = lib.mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/mpd/mpd.fifo";
    };

    music-directory = lib.mkOption {
      type = types.str;
      default = config.xdg.userDirs.music;
    };

    pid-file = lib.mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/mpd/mpd.pid";
    };

    playlist-directory = lib.mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/mpd/playlists";
    };

    state-file = lib.mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/mpd/mpd.state";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mpd = {
      enable = true;

      inherit (cfg) package;
      dbFile = cfg.db-file;
      musicDirectory = cfg.music-directory;
      playlistDirectory = cfg.playlist-directory;

      network = {
        startWhenNeeded = true;
        listenAddress = "127.0.0.1";
        port = 6600;
      };

      extraConfig = ''
        user "${user.name}"

        pid_file "${cfg.pid-file}"
        state_file "${cfg.state-file}"

        follow_inside_symlinks "yes"
        save_absolute_paths_in_playlists "no"

        input {
          plugin "curl"
        }

        audio_output {
          type "pulse"
          name "Pulse output"
        }

        audio_output {
          type "fifo"
          name "fifo"
          path "${cfg.fifo-file}"
          format "44100:16:2"
        }
      '';
    };
  };
}

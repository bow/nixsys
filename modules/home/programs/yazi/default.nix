{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  libcfg = lib.nixsys.home;

  shellBash = libcfg.isShellBash user;

  cfg = config.nixsys.home.programs.yazi;
in
{
  options.nixsys.home.programs.yazi = {
    enable = lib.mkEnableOption "nixsys.home.programs.yazi" // {
      default = true;
    };
    package = lib.mkPackageOption pkgs "yazi" { };
  };

  config = lib.mkIf cfg.enable {

    programs.yazi = {
      enable = true;

      inherit (cfg) package;
      enableBashIntegration = shellBash;

      keymap = {
        mgr.prepend_keymap = [
          {
            on = "<C-h>";
            run = "hidden toggle";
          }
          {
            on = "<C-j>";
            run = "arrow [5]";
          }
          {
            on = "<C-k>";
            run = "arrow [-5]";
          }
          {
            on = "<C-q>";
            run = "quit";
          }
          {
            on = "<Enter>";
            run = "plugin smart-enter";
          }
        ];
      };

      plugins = {
        inherit (pkgs.yaziPlugins) bypass smart-enter starship;
      };

      settings = {
        mgr = {
          linemode = "mtime";
          ratio = [
            1
            2
            3
          ];
          show_hidden = false;
          sort_by = "natural";
          sort_dir_first = true;
          sort_sensitive = true;
          sort_translit = false;
        };
        preview = {
          tab_size = 4;
        };
      };
    };
  };
}

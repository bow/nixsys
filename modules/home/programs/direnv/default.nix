{
  config,
  lib,
  user,
  ...
}:
let
  libcfg = lib.nixsys.home;

  shellBash = libcfg.isShellBash user;

  cfg = config.nixsys.home.programs.direnv;
in
{
  options.nixsys.home.programs.direnv = {
    enable = lib.mkEnableOption "nixsys.home.programs.direnv";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = shellBash;
      config = {
        global = {
          warn_timeout = "5m";
          hide_env_diff = false;
        };
      };
      nix-direnv.enable = true;
    };
  };
}

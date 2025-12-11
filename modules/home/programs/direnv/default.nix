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

  cfg = config.nixsys.home.programs.direnv;
in
{
  options.nixsys.home.programs.direnv = {
    enable = lib.mkEnableOption "nixsys.home.programs.direnv";
    package = lib.mkPackageOption pkgs "direnv" { };
    nix-direnv-package = lib.mkPackageOption pkgs "nix-direnv" { };
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;

      inherit (cfg) package;
      enableBashIntegration = shellBash;
      config = {
        global = {
          warn_timeout = "5m";
          hide_env_diff = false;
        };
      };
      nix-direnv = {
        enable = true;
        package = cfg.nix-direnv-package;
      };
    };
  };
}

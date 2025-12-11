{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  libcfg = lib.nixsys.home;

  neovimEnabled = libcfg.isNeovimEnabled config;
  shellBash = libcfg.isShellBash user;

  cfg = config.nixsys.home.programs.fzf;
in
{
  options.nixsys.home.programs.fzf = {
    enable = lib.mkEnableOption "nixsys.home.programs.fzf";
    package = lib.mkPackageOption pkgs.unstable "fzf" { };
  };

  config = lib.mkIf cfg.enable {

    programs.fzf = {
      enable = true;
      inherit (cfg) package;
      enableBashIntegration = shellBash;

      colors = {
        "fg" = "#ebdbb2";
        "bg" = "#282828";
        "hl" = "#fabd2f";
        "fg+" = "#ebdbb2";
        "bg+" = "#3c3836";
        "hl+" = "#fabd2f";
        "info" = "#83a598";
        "prompt" = "#bdae93";
        "spinner" = "#fabd2f";
        "pointer" = "#83a598";
        "marker" = "#fe8019";
        "header" = "#665c54";
      };
    };

    programs.neovim.extraPackages = lib.mkIf neovimEnabled [ cfg.package ];
  };
}

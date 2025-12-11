{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.home.programs.neovim;
in
{
  options.nixsys.home.programs.neovim = {
    enable = lib.mkEnableOption "nixsys.home.programs.neovim";
    as-default-editor = lib.mkOption {
      description = "Whether to set the EDITOR environment variable to neovim or not";
      type = types.bool;
    };
    package = lib.mkPackageOption pkgs.unstable "neovim-unwrapped" { };
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      inherit (cfg) package;
      enable = true;
      viAlias = false;
      vimAlias = false;
      vimdiffAlias = true;
      plugins = [
        pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars
        pkgs.unstable.vimPlugins.nvim-treesitter
      ];
      extraPackages = [
        pkgs.unstable.tree-sitter
        pkgs.unstable.lua54Packages.jsregexp
      ];
    };

    xdg.configFile = {
      "nvim" = {
        source = ../../../../dotfiles/nvim;
        recursive = true;
      };
    };

    home.sessionVariables = lib.mkIf cfg.as-default-editor {
      EDITOR = lib.mkForce "nvim";
    };
  };
}

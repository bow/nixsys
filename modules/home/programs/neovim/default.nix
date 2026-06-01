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
      default = true;
    };
    package = lib.mkPackageOption pkgs.unstable "neovim-unwrapped" { };
    extended = lib.mkOption { type = types.bool; };
  };

  config =
    let
      luaPackages = pkgs.unstable.lua54Packages;

      inherit (luaPackages) jsregexp tree-sitter-cli;
      inherit (pkgs.unstable) tree-sitter;

      tree-sitter-plugins-all = pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars;
    in
    lib.mkIf cfg.enable {
      programs.neovim = {
        inherit (cfg) package;
        enable = true;
        viAlias = false;
        vimAlias = false;
        vimdiffAlias = true;
        plugins = [ tree-sitter-plugins-all ];
        extraPackages = lib.mkIf cfg.extended [
          jsregexp
          tree-sitter
          tree-sitter-cli
        ];
        withPython3 = true;
        withRuby = true;
      };

      xdg.configFile = lib.mkIf cfg.extended {
        "nvim" = {
          source = ../../../../dotfiles/nvim;
          recursive = true;
        };
        "nvim/lua/config/local.lua" = {
          text =
            let
              tree-sitter-grammars-path = pkgs.symlinkJoin {
                name = "nvim-treesitter-grammars";
                paths = tree-sitter-plugins-all.dependencies;
              };
            in
            ''
              vim.opt.runtimepath:append("${tree-sitter-cli}")
              vim.opt.runtimepath:append("${tree-sitter-plugins-all}")
              vim.opt.runtimepath:append("${tree-sitter-grammars-path}")
            '';
        };
      };

      home.sessionVariables = lib.mkIf cfg.as-default-editor {
        EDITOR = lib.mkForce "nvim";
      };
    };
}

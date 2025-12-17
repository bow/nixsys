{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixsys.home.programs.zathura;
in
{
  options.nixsys.home.programs.zathura = {
    enable = lib.mkEnableOption "nixsys.home.programs.zathura";
    package = lib.mkPackageOption pkgs.unstable "zathura" { };
  };

  config = lib.mkIf cfg.enable {

    programs.zathura = {
      inherit (cfg) package;
      enable = true;
      mappings = {
        "[index] q" = "quit";
      };
      options = {
        selection-clipboard = "clipboard";
        statusbar-basename = true;

        guioptions = "cv";
        font = "Iosevka Term SS03 Light 12";

        default-bg = "#151515";
        default-fg = "#ebdbb2";

        completion-group-fg = "#ebdbb2";
        completion-group-bg = "#458588";

        inputbar-fg = "#ebdbb2";
        inputbar-bg = "#151515";

        completion-highlight-bg = "#fabd2f";
        completion-highlight-fg = "#151515";

        highlight-color = "#6bb95f";
        highlight-active-color = "#b769c3";
      };
    };

    xdg =
      let
        desktopEntryName = "zathura";
        mimeTypes = [ "application/pdf" ];
      in
      {
        desktopEntries.${desktopEntryName} = {
          name = "Zathura";
          comment = "Open PDF files in zathura";
          exec = "${cfg.package}/bin/zathura %f";
          terminal = false;
          icon = "zathura";
          categories = [
            "Office"
            "Viewer"
          ];
          mimeType = mimeTypes;
        };
        mimeApps = {
          enable = true;
          defaultApplications = builtins.listToAttrs (
            builtins.map (name: {
              inherit name;
              value = [ "${desktopEntryName}.desktop" ];
            }) mimeTypes
          );
        };
      };
  };
}

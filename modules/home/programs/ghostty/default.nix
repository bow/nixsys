{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.home;

  handlerScriptName = "ghostty-text-handler";
  ghostty-text-handler = pkgs.writeShellScriptBin "${handlerScriptName}" ''
    FILE_PATH="''${1}"
    ${cfg.package}/bin/ghostty -e ${pkgs.runtimeShell} -c "''${EDITOR} \"''${FILE_PATH}\"" &
  '';

  mimeTypes = [
    "application/json"
    "application/xml"
    "text/css"
    "text/diff"
    "text/markdown"
    "text/plain"
    "text/x-c"
    "text/x-c++"
    "text/x-devicetree-source"
    "text/x-perl"
    "text/x-python"
    "text/x-ruby"
    "text/x-shellscript"
    "text/x-sql"
  ];

  cfg = config.nixsys.home.programs.ghostty;
in
{
  options.nixsys.home.programs.ghostty = {
    enable = lib.mkEnableOption "nixsys.home.programs.ghostty" // {
      default = libcfg.isDesktopEnabled config;
    };
    package = lib.mkPackageOption pkgs.unstable "ghostty" { };
  };

  config = lib.mkIf cfg.enable {

    home.packages = [ cfg.package ];

    xdg =
      let
        desktopEntryName = "ghostty-editor";
      in
      {
        configFile = {
          "ghostty/config" = {
            text = ''
              app-notifications = no-clipboard-copy
              clipboard-paste-protection = false
              clipboard-trim-trailing-spaces = true
              copy-on-select = clipboard
              cursor-style = bar
              background-opacity = 0.96
              font-family = Iosevka Term SS03 Light
              font-family-bold = Iosevka Term SS03 Medium
              font-feature = calt
              link-url = true
              resize-overlay = never
              selection-invert-fg-bg = true
              theme = Gruvbox Dark Hard
              window-decoration = false
              window-padding-x = 3
            '';
          };
        };

        desktopEntries.${desktopEntryName} = {
          name = "Ghostty editor";
          comment = ''Open text files in ''$EDITOR in a new Ghostty terminal'';
          exec = "${ghostty-text-handler}/bin/${handlerScriptName} %f";
          terminal = false;
          icon = "ghostty";
          categories = [
            "Utility"
            "TextEditor"
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

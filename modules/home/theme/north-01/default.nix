{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.home.theme.north-01;
in
{
  options.nixsys.home.theme.north-01 = {
    enable = lib.mkEnableOption "nixsys.home.theme.north-01";
    wallpaper = lib.mkOption {
      type = types.package;
      default = pkgs.local.wallpapers.francesco-ungaro-lcQzCo-X1vM-unsplash;
    };
  };

  config = lib.mkIf cfg.enable {
    nixsys.home.theme.active = lib.mkForce {
      desktop.bg = "${cfg.wallpaper}/original";
      lock-screen = {
        bg = "${cfg.wallpaper}/blurred";
        font = {
          name = "Titillium";
          package = pkgs.local.titillium-font;
        };
        colors = rec {
          time = light;
          greeter = dark;

          light = "#ffffffff";
          dark = "#1d2021ee";
          ring = "#007c5bff";
          ring-hl = "#e3ac2dff";
          ring-bs = "#d1472fff";
          ring-sep = "#00000000";
        };
      };
    };
  };
}

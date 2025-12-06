{
  config,
  pkgs,
  lib,
  ...
}:
let
  mkWallpaperDrv =
    wallpaper:
    pkgs.stdenvNoCC.mkDerivation {
      pname = "${wallpaper.name}";
      version = "0.0.0";

      src = pkgs.fetchurl {
        inherit (wallpaper) sha256;
        name = "${wallpaper.name}-source";
        url = "${wallpaper.url}";
      };

      unpackPhase = "true";

      buildPhase = ''
        mkdir -p $out
        cp $src $out/original
        ${pkgs.imagemagick}/bin/magick $src -blur 0x8 $out/blurred
      '';
    };

  wallpaper = mkWallpaperDrv {
    name = "francesco-ungaro-lcQzCo-X1vM-unsplash";
    ext = "jpg";
    url = "https://images.unsplash.com/photo-1729839472414-4f28edcb5b80?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb&dl=francesco-ungaro-lcQzCo-X1vM-unsplash.jpg&w=2400";
    sha256 = "a36d6e0231bc57900e9725675664d9fa075996f4fee1bd96580f183eac5b4685";
  };

  cfg = config.nixsys.home.theme.north-01;
in
{
  options.nixsys.home.theme.north-01 = {
    enable = lib.mkEnableOption "nixsys.home.theme.north-01";
  };

  config = lib.mkIf cfg.enable {
    nixsys.home.theme.active = lib.mkForce {
      desktop.bg = "${wallpaper}/original";
      lock-screen = {
        bg = "${wallpaper}/blurred";
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

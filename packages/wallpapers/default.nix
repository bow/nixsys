{
  pkgs,
  ...
}:
let
  mkWallpaperAttrs =
    wallpaper:
    let
      drv = pkgs.stdenvNoCC.mkDerivation {
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
    in
    {
      inherit (wallpaper) name;
      value = drv;
    };
in
pkgs.lib.listToAttrs (
  builtins.map mkWallpaperAttrs [
    {
      name = "francesco-ungaro-lcQzCo-X1vM-unsplash";
      ext = "jpg";
      url = "https://images.unsplash.com/photo-1729839472414-4f28edcb5b80?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb&dl=francesco-ungaro-lcQzCo-X1vM-unsplash.jpg&w=2400";
      sha256 = "a36d6e0231bc57900e9725675664d9fa075996f4fee1bd96580f183eac5b4685";
    }
  ]
)

{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nixsys.home.desktop.fonts;
in
{
  options.nixsys.home.desktop.fonts = {
    enable = lib.mkEnableOption "nixsys.home.desktop.fonts";
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts.monospace = [ "Iosevka SS03" ];
      };
    };

    home.packages = [
      (pkgs.iosevka-bin.override { variant = "SS03"; })
      pkgs.nerd-fonts.droid-sans-mono
      pkgs.nerd-fonts.inconsolata
      pkgs.nerd-fonts.ubuntu
      pkgs.nerd-fonts.ubuntu-sans
      pkgs.noto-fonts
      pkgs.noto-fonts-color-emoji
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-cjk-serif
      pkgs.siji

      pkgs.unstable.font-awesome

      pkgs.local.awesome-terminal-fonts
      pkgs.local.titillium-fonts
    ];
  };
}

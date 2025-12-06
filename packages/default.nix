{
  pkgs,
  ...
}:
{
  awesome-terminal-fonts = pkgs.callPackage ./awesome-terminal-fonts { };
  polybar-module-battery-combined-sh = pkgs.callPackage ./polybar-module-battery-combined-sh { };
  titillium-fonts = pkgs.callPackage ./titillium-fonts { };
}

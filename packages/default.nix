{
  pkgs,
  ...
}:
{
  awesome-terminal-fonts = pkgs.callPackage ./awesome-terminal-fonts { };
  titillium-fonts = pkgs.callPackage ./titillium-fonts { };
}

{
  pkgs,
  ...
}:
{
  awesome-terminal-fonts = pkgs.callPackage ./awesome-terminal-fonts { };
  titillium-fonts = pkgs.callPackage ./titillium-fonts { };
  nxn = pkgs.callPackage ./nxn { };
  psc = pkgs.callPackage ./psc { };
}

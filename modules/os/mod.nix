{ lib, ... }:
{
  nixsys = {
    imports = lib.nixsys.listDefaultNixFilesRecursive ./.;
  };
}

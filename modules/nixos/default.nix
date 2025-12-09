{
  lib,
  ...
}:
{
  options.nixsys = {
    enable = lib.mkEnableOption "nixsys";
  };
}

{
  lib,
  ...
}:
{
  options.nixsys.os = {
    enable = lib.mkEnableOption "nixsys.os";
    hostname = lib.mkOption { type = lib.types.str; };
  };
}

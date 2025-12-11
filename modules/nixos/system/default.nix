{
  lib,
  ...
}:
{
  options.nixsys.system = {
    hostname = lib.mkOption { type = lib.types.str; };
  };
}

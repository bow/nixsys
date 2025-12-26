{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.nixsys.os.enable {
    fonts.enableDefaultPackages = true;
  };
}

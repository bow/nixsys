{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.nixsys.os.enable {
    security = {
      sudo = {
        enable = true;
        wheelNeedsPassword = true;
        execWheelOnly = true;
        keepTerminfo = true;
      };
    };
  };
}

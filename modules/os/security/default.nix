{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.nixsys.os.enable {
    security = {
      polkit.enable = lib.mkDefault true;
      sudo = {
        enable = true;
        wheelNeedsPassword = true;
        execWheelOnly = true;
        keepTerminfo = true;
      };
    };
  };
}

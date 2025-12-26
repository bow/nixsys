{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.nixsys.os.kernel;
in
{
  options.nixsys.os.kernel = {
    package = options.boot.kernelPackages // {
      description = "Sets the system kernel";
      default = pkgs.linuxPackages_latest;
    };
  };

  config = lib.mkIf config.nixsys.os.enable {
    boot.kernelPackages = cfg.package;
  };
}

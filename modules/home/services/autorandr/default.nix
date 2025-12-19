{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.home.services.autorandr;
in
{
  options.nixsys.home.services.autorandr = {
    enable = lib.mkEnableOption "nixsys.home.services.autorandr" // {
      default = config.nixsys.home.programs.autorandr.enable;
    };
    package = lib.mkOption {
      type = types.package;
      default = config.nixsys.home.programs.autorandr.package;
    };
  };

  config = lib.mkIf cfg.enable {

    services.autorandr = {
      enable = true;

      inherit (cfg) package;
    };
  };
}

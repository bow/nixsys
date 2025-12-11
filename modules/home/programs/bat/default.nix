{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixsys.home.programs.bat;
in
{
  options.nixsys.home.programs.bat = {
    enable = lib.mkEnableOption "nixsys.home.programs.bat";
    package = lib.mkPackageOption pkgs.unstable "bat" { };
  };

  config = lib.mkIf cfg.enable {
    programs.bat = {
      inherit (cfg) package;
      enable = true;
      config = {
        theme = "gruvbox-dark";
      };
    };
  };
}

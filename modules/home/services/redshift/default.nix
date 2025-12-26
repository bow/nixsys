{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.nixsys.home.services.redshift;
in
{
  options.nixsys.home.services.redshift = {
    enable = lib.mkEnableOption "nixsys.home.services.redshift";
    package = lib.mkPackageOption pkgs "redshift" { };
  };

  config = lib.mkIf cfg.enable {
    services.redshift = {
      enable = true;

      inherit (user.location) latitude longitude;
      provider = "manual";
      settings = {
        redshift = {
          fade = 1;
        };
      };
      temperature = {
        day = 5800;
        night = 4000;
      };
    };

    systemd.user.services.redshift = {
      Install.WantedBy = lib.mkForce [ "default.target" ];
      # FIXME: This should be systemctl --user import-environment DISPLAY XAUTHORITY somewhere.
      Service.Environment = [ "DISPLAY=:0" ];
      Unit.After = lib.mkForce [ "display-manager.service" ];
    };
  };
}

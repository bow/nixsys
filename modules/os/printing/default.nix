{
  config,
  pkgs,
  lib,
  ...
}:
let
  libcfg = lib.nixsys.os;
  mainUserDefined = libcfg.isMainUserDefined config;

  cfg = config.nixsys.os.printing;
in
{
  options.nixsys.os.printing = {
    enable = lib.mkEnableOption "nixsys.os.printing";
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = lib.mkDefault true;
      nssmdns4 = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
    };

    services.printing = {
      enable = lib.mkDefault true;
      drivers = [
        pkgs.cups-filters
        pkgs.cups-browsed
        pkgs.hplipWithPlugin
      ];
    };

    users.users = lib.optionalAttrs mainUserDefined {
      "${config.nixsys.os.users.main.name}".extraGroups = lib.optionals config.nixsys.os.users.main.trusted [
        "lpadmin"
      ];
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.os;

  mainUser = libcfg.getMainUser config;
  mainUserDefined = libcfg.isMainUserDefined config;

  cfg = config.nixsys.os.virtualization.host.docker;
in
{
  options.nixsys.os.virtualization.host.docker = {
    enable = lib.mkEnableOption "nixsys.os.virtualization.host.docker";
    package = lib.mkPackageOption pkgs.unstable "docker" { };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.mkIf mainUserDefined {
      ${mainUser.name}.extraGroups = [ "docker" ];
    };

    environment.systemPackages = [
      pkgs.unstable.docker-buildx
      pkgs.unstable.docker-compose
    ];

    virtualisation = {
      oci-containers.backend = "docker";
      docker = {
        inherit (cfg) package;
        enable = true;
        autoPrune = {
          enable = true;
          persistent = true;
          dates = "daily";
          flags = [
            "--force"
            "--all"
            "--volumes"
          ];
        };
      };
    };
  };
}

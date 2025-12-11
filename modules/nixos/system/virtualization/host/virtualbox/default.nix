{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.nixos;

  mainUser = libcfg.getMainUser config;
  mainUserDefined = libcfg.isMainUserDefined config;

  cfg = config.nixsys.system.virtualization.host.virtualbox;
in
{
  options.nixsys.system.virtualization.host.virtualbox = {
    enable = lib.mkEnableOption "nixsys.system.virtualization.host.virtualbox";
    package = lib.mkPackageOption pkgs "virtualbox" { };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.mkIf mainUserDefined {
      ${mainUser.name}.extraGroups = [ "vboxusers" ];
    };

    virtualisation.virtualbox.host = {
      enable = true;

      inherit (cfg) package;
      enableHardening = true;
      enableExtensionPack = true;
    };
  };
}

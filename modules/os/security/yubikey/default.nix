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

  cfg = config.nixsys.os.security.yubikey;
in
{
  options.nixsys.os.security.yubikey = {
    enable = lib.mkEnableOption "nixsys.os.security.yubikey";
  };

  config = lib.mkIf cfg.enable {

    users.users = lib.mkIf mainUserDefined {
      ${mainUser.name}.packages = [
        pkgs.yubioath-flutter
        pkgs.yubikey-manager
      ];
    };

    services = {
      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];
    };
  };
}

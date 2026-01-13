{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.os;

  autologinEnabled = lib.hasAttr "auto-login" cfg.settings && cfg.settings.auto-login;
  mainUser = libcfg.getMainUser config;
  desktopEnabled = libcfg.isDesktopEnabled config;
  xorgEnabled = libcfg.isXorgEnabled config;

  cfg = mainUser.session.greetd;
in
{
  options.nixsys.os.users.main.session.greetd = {
    enable = lib.mkEnableOption "nixsys.os.users.main.session.greetd" // {
      default = desktopEnabled;
    };
    vt = lib.mkOption {
      type = types.ints.positive;
      default = 7;
      description = "Sets services.greetd.settings.terminal.vt";
    };
    settings = lib.mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {

    programs.seahorse.enable = true;

    security.pam.services.greetd.enableGnomeKeyring = true;

    services = {

      displayManager.autoLogin = lib.mkIf autologinEnabled {
        enable = true;
        user = mainUser.name;
      };

      gnome = {
        gcr-ssh-agent.enable = lib.mkDefault false;
        gnome-keyring.enable = lib.mkDefault true;
      };

      greetd = {
        enable = true;
        settings = {
          terminal.vt = lib.mkForce cfg.vt;
          default_session = lib.mkIf xorgEnabled {
            command = "${pkgs.xorg.xinit}/bin/startx";
          };
          initial_session = lib.mkIf (autologinEnabled && xorgEnabled) {
            command = "${pkgs.xorg.xinit}/bin/startx";
            user = mainUser.name;
          };
        };
      };
    };
  };
}

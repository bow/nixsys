{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.os.users.main.session.xorg;
in
{
  options.nixsys.os.users.main.session.xorg = {
    enable = lib.mkEnableOption "nixsys.os.users.main.session.xorg" // {
      default = config.nixsys.os.users.main.session.i3.enable;
    };
    enable-dpms = lib.mkOption {
      type = types.bool;
      default = true;
    };
    standby-time = lib.mkOption {
      type = types.int;
      default = 15;
    };
    suspend-time = lib.mkOption {
      type = types.int;
      default = 0;
    };
    blank-time = lib.mkOption {
      type = types.int;
      default = 30;
    };
    off-time = lib.mkOption {
      type = types.int;
      default = 30;
    };
  };

  config = lib.mkIf cfg.enable {

    environment.etc."X11/xorg.conf.d/99-dpms.conf".text =
      if cfg.enable-dpms then
        ''
          Section "ServerFlags"
              Option "StandbyTime" "${toString cfg.standby-time}"
              Option "SuspendTime" "${toString cfg.suspend-time}"
              Option "BlankTime"   "${toString cfg.blank-time}"
              Option "OffTime"     "${toString cfg.off-time}"
          EndSection
        ''
      else
        ''
          Section "Extensions"
              Option "DPMS" "false"
          EndSection
        '';
  };
}

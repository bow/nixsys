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
      default = 60;
    };
    off-time = lib.mkOption {
      type = types.int;
      default = 60;
    };
  };

  config = lib.mkIf cfg.enable {

    services.xserver.config = lib.optionalString (!cfg.enable-dpms) (
      lib.mkAfter ''
        Section "Extensions"
            Option "DPMS" "false"
        EndSection
      ''
    );

    services.xserver.serverFlagsSection = lib.optionalString cfg.enable-dpms (
      lib.optionalString (cfg.standby-time > 0) ''
        Option "StandbyTime" "${toString cfg.standby-time}"
      ''
      + (
        lib.optionalString (cfg.suspend-time > 0) ''
          Option "SuspendTime" "${toString cfg.suspend-time}"
        ''
      )
      + (
        lib.optionalString (cfg.blank-time > 0) ''
          Option "BlankTime"   "${toString cfg.blank-time}"
        ''
      )
      + (
        lib.optionalString (cfg.off-time > 0) ''
          Option "OffTime"     "${toString cfg.off-time}"
        ''
      )
    );
  };
}

{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.nixos;

  mainUser = libcfg.getMainUserOrNull config;

  cfg = config.nixsys.system.backup.snapper;
in
{
  options.nixsys.system.backup.snapper = {
    enable-home-snapshots = lib.mkOption {
      type = types.bool;
      description = "Whether to enable regular /home snapshots or not";
    };
  };

  config = lib.mkIf cfg.enable-home-snapshots {

    services.snapper = {
      configs = lib.optionalAttrs cfg.enable-home-snapshots {
        home = {
          SUBVOLUME = "/home";
          FSTYPE = "btrfs";
          SPACE_LIMIT = 0.5;
          FREE_LIMIT = 0.2;
          ALLOW_USERS = lib.optionals (mainUser != null) [ mainUser.name ];
          SYNC_ACL = false;
          BACKGROUND_COMPARISON = true;
          NUMBER_CLEANUP = true;
          NUMBER_MIN_AGE = 3600;
          NUMBER_LIMIT = 50;
          NUMBER_LIMIT_IMPORTANT = 10;
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_MIN_AGE = 3600;
          TIMELINE_LIMIT_HOURLY = 10;
          TIMELINE_LIMIT_DAILY = 7;
          TIMELINE_LIMIT_WEEKLY = 0;
          TIMELINE_LIMIT_MONTHLY = 0;
          TIMELINE_LIMIT_QUARTERLY = 0;
          TIMELINE_LIMIT_YEARLY = 0;
          EMPTY_PRE_POST_CLEANUP = true;
          EMPTY_PRE_POST_MIN_AGE = 3600;
        };
      };
    };
  };
}

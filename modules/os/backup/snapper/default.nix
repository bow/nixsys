{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.os;

  mainUser = libcfg.getMainUserOrNull config;

  cfg = config.nixsys.os.backup.snapper;
in
{
  options.nixsys.os.backup.snapper = {
    enable-home-snapshots = lib.mkOption {
      description = "Whether to enable regular /home snapshots or not";
      type = types.bool;
      default = false;
    };
    enable-machine-data-dir-snapshots = lib.mkOption {
      description = "Whether to enable regular machine data directory snapshots or not";
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable-home-snapshots {

    services.snapper = {
      configs =
        lib.optionalAttrs cfg.enable-home-snapshots {
          home = {
            SUBVOLUME = "/home";
            FSTYPE = "btrfs";
            SPACE_LIMIT = 0.3;
            FREE_LIMIT = 0.25;
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
            TIMELINE_LIMIT_HOURLY = 6;
            TIMELINE_LIMIT_DAILY = 7;
            TIMELINE_LIMIT_WEEKLY = 0;
            TIMELINE_LIMIT_MONTHLY = 0;
            TIMELINE_LIMIT_QUARTERLY = 0;
            TIMELINE_LIMIT_YEARLY = 0;
            EMPTY_PRE_POST_CLEANUP = true;
            EMPTY_PRE_POST_MIN_AGE = 3600;
          };
        }
        // lib.optionalAttrs cfg.enable-machine-data-dir-snapshots {
          machine-data-dir = {
            SUBVOLUME = config.nixsys.os.machine-data-dir;
            FSTYPE = "btrfs";
            SPACE_LIMIT = 0.3;
            FREE_LIMIT = 0.25;
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
            TIMELINE_LIMIT_HOURLY = 3;
            TIMELINE_LIMIT_DAILY = 7;
            TIMELINE_LIMIT_WEEKLY = 1;
            TIMELINE_LIMIT_MONTHLY = 1;
            TIMELINE_LIMIT_QUARTERLY = 1;
            TIMELINE_LIMIT_YEARLY = 0;
            EMPTY_PRE_POST_CLEANUP = true;
            EMPTY_PRE_POST_MIN_AGE = 3600;
          };
        };
    };
  };
}

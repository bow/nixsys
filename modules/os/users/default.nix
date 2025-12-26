{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.os;

  # Shortcut to make a simple option with a default.
  mkOpt =
    type: default: description:
    lib.mkOption { inherit type default description; };

  # Shortcut to make a simple option without any defaults.
  mkOpt' = type: description: lib.mkOption { inherit type description; };

  mainUserDefined = libcfg.isMainUserDefined config;

  cfg = config.nixsys.os.users;
in
{
  options.nixsys.os.users = {
    mutable = mkOpt types.bool false "Sets users.mutableUsers in NixOS config";
    main = {
      name = mkOpt types.str null "User name of the main user";
      full-name = mkOpt' types.str "Full name of the main user";
      email = mkOpt' types.str "Email of the main user";
      location = {
        city = mkOpt' types.str "City where the user is located";
        latitude = mkOpt' (types.either types.str types.float) "Location latitude";
        longitude = mkOpt' (types.either types.str types.float) "Location longitude";
      };
      timezone = mkOpt types.str "UTC" "Timezone";

      home-directory = mkOpt types.str "/home/${cfg.main.name}" "Path to the user's home directory";
      extra-groups = mkOpt (types.listOf types.str) [ ] "Additional groups of the user";
      shell = mkOpt' (types.enum [ "bash" ]) "Login shell of the user";
      trusted = mkOpt types.bool false "Whether to add the user to the trusted user list or not";
    };
  };

  config = lib.mkIf mainUserDefined {

    users = {
      mutableUsers = cfg.mutable;
      users.${cfg.main.name} = {
        description = cfg.main.full-name;
        extraGroups = cfg.main.extra-groups ++ (lib.optionals cfg.main.trusted [ "wheel" ]);
        isNormalUser = true;
      };
    };

    nix.settings.trusted-users = lib.optionals cfg.main.trusted [ "${cfg.main.name}" ];
  };
}

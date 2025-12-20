{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.home;

  shellBash = libcfg.isShellBash user;

  cfg = config.nixsys.home.services.ssh-agent;
in
{
  options.nixsys.home.services.ssh-agent = {
    enable = lib.mkEnableOption "nixsys.home.services.ssh-agent";
    default-maximum-identity-lifetime = lib.mkOption {
      type = types.nullOr types.ints.positive;
      default = 3600;
    };
    package = lib.mkPackageOption pkgs "openssh" { };
  };

  config = lib.mkIf cfg.enable {

    services.ssh-agent = {
      enable = true;

      inherit (cfg) package;
      enableBashIntegration = shellBash;
      defaultMaximumIdentityLifetime = cfg.default-maximum-identity-lifetime;
    };
  };
}

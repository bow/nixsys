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
  xorgEnabled = libcfg.isXorgEnabled config;

  cfg = config.nixsys.home.services.gpg-agent;
in
{
  options.nixsys.home.services.gpg-agent = {
    enable = lib.mkEnableOption "nixsys.home.services.gpg-agent";

    default-cache-ttl = lib.mkOption {
      description = "Sets services.gpg-agent.defaultCacheTtl";
      type = types.nullOr types.ints.positive;
      default = 86400;
    };

    default-cache-ttl-ssh = lib.mkOption {
      description = "Sets services.gpg-agent.defaultCacheTtlSsh";
      type = types.nullOr types.ints.positive;
      default = 86400;
    };

    exported-as-ssh = lib.mkOption {
      description = "Sets services.gpg-agent.sshKeys";
      type = types.nullOr (types.listOf types.str);
      default = null;
    };

    max-cache-ttl = lib.mkOption {
      description = "Sets services.gpg-agent.defaultCacheTtl";
      type = types.nullOr types.ints.positive;
      default = 14 * 86400;
    };

    max-cache-ttl-ssh = lib.mkOption {
      description = "Sets services.gpg-agent.defaultCacheTtlSsh";
      type = types.nullOr types.ints.positive;
      default = 7 * 86400;
    };

    package = lib.mkPackageOption pkgs "gnupg" { };
  };

  config = lib.mkIf cfg.enable {

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = cfg.default-cache-ttl;
      defaultCacheTtlSsh = cfg.default-cache-ttl-ssh;
      enableBashIntegration = shellBash;
      enableSshSupport = true;
      maxCacheTtl = cfg.max-cache-ttl;
      maxCacheTtlSsh = cfg.max-cache-ttl-ssh;
      pinentry.package = if xorgEnabled then pkgs.pinentry-gtk2 else pkgs.pinentry-tty;
      sshKeys = cfg.exported-as-ssh;
    };
  };
}

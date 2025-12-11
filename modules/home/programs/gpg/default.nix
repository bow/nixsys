{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.home;

  xorgEnabled = libcfg.isXorgEnabled config;

  cfg = config.nixsys.home.programs.gpg;
in
{
  options.nixsys.home.programs.gpg = {
    enable = lib.mkEnableOption "nixsys.home.programs.gpg";

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

    mutable-keys = lib.mkOption {
      description = "Sets programs.gpg.mutableKeys";
      type = types.bool;
      default = true;
    };

    mutable-trust = lib.mkOption {
      description = "Sets programs.gpg.mutableTrust";
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      mutableKeys = cfg.mutable-keys;
      mutableTrust = cfg.mutable-trust;
    };

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = cfg.default-cache-ttl;
      defaultCacheTtlSsh = cfg.default-cache-ttl-ssh;
      enableBashIntegration = true;
      enableSshSupport = true;
      maxCacheTtl = cfg.max-cache-ttl;
      maxCacheTtlSsh = cfg.max-cache-ttl-ssh;
      pinentry.package = if xorgEnabled then pkgs.pinentry-gtk2 else pkgs.pinentry-tty;
      sshKeys = cfg.exported-as-ssh;
    };
  };
}

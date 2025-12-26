{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.os.servers.ssh;
in
{
  options.nixsys.os.servers.ssh = {
    enable = lib.mkEnableOption "nixsys.os.servers.ssh";

    allow-users = lib.mkOption {
      description = "Sets services.openssh.settings.AllowUsers";
      type = types.nullOr (types.listOf types.str);
      default = null;
    };

    generate-hostkey = lib.mkOption {
      description = "Whether to create an SSH host key or not";
      type = types.bool;
      default = true;
    };

    password-authentication = lib.mkOption {
      description = "Sets services.openssh.settings.PasswordAuthentication";
      type = types.bool;
      default = true;
    };

    permit-root-login = lib.mkOption {
      description = "Sets services.openssh.settings.PermitRootLogin";
      type = types.str;
      default = "no";
    };

    ports = lib.mkOption {
      description = "Sets services.openssh.ports";
      type = types.listOf types.port;
      default = [ 22 ];
    };

    x11-forwarding = lib.mkOption {
      description = "Sets services.openssh.settings.X11Forwarding";
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;

      inherit (cfg) ports;

      hostKeys = lib.optionals cfg.generate-hostkey [
        {
          path = "/etc/ssh/hostkey";
          type = "ed25519";
        }
      ];
      openFirewall = true;

      settings = {
        AllowUsers = cfg.allow-users;
        PasswordAuthentication = cfg.password-authentication;
        PermitRootLogin = cfg.permit-root-login;
        X11Forwarding = cfg.x11-forwarding;
      };
    };
  };
}

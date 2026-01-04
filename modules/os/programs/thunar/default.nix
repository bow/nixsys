# This module is defined in the system level here instead of home-manager level because
# we also need to modify the system udev and systemd (done through the NixOS programs.thunar module).
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.os;

  xorgEnabled = libcfg.isXorgEnabled config;

  cfg = config.nixsys.os.programs.thunar;
in
{
  options.nixsys.os.programs.thunar = {
    enable = lib.mkEnableOption "nixsys.home.programs.thunar" // {
      default = xorgEnabled;
    };
    package = lib.mkPackageOption pkgs [ "xfce" "thunar" ] { };
    # FIXME: Expose this cleanly in systems/ or profiles/.
    with-dropbox-plugin = lib.mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {

    # Because NixOS's programs.thunar also adds to environment.systemPackages.
    environment.systemPackages = [
      pkgs.adwaita-icon-theme
      pkgs.sshfs
    ];

    programs = {
      thunar = {
        enable = true;
        plugins = [
          pkgs.xfce.thunar-archive-plugin
          pkgs.xfce.thunar-volman
        ]
        ++ lib.optionals cfg.with-dropbox-plugin [ pkgs.xfce.thunar-dropbox-plugin ];
      };
      xfconf.enable = true;
    };

    services = {
      gvfs.enable = true;
      tumbler.enable = true;
    };
  };
}

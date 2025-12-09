{
  config,
  lib,
  pkgs,
  ...
}:
let
  libcfg = lib.nixsys.nixos;

  mainUser = libcfg.getMainUser config;
  mainUserDefined = libcfg.isMainUserDefined config;

  cfg = config.nixsys.system.audio.pulseaudio;
in
{
  options.nixsys.system.audio.pulseaudio = {
    enable = lib.mkEnableOption "nixsys.system.audio.pulseaudio";
    package = lib.mkPackageOption pkgs "pulseaudioFull" { };
  };

  config = lib.mkIf cfg.enable {

    nixpkgs.config.pulseaudio = true;

    hardware.pulseaudio = {
      enable = true;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };

    security.rtkit.enable = true;

    users.users = lib.mkIf mainUserDefined {
      ${mainUser.name}.extraGroups = [ "audio" ];
    };
  };
}

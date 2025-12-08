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

  cfg = config.nixsys.system.hardware.pulseaudio;
in
{
  options.nixsys.system.hardware.pulseaudio = {
    enable = lib.mkEnableOption "nixsys.system.hardware.pulseaudio";
    package = lib.mkPackageOption pkgs "pulseaudioFull" { };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.pulseaudio = true;
    hardware.pulseaudio.enable = true;
    security.rtkit.enable = true;

    users.users = lib.mkIf mainUserDefined {
      ${mainUser.name}.extraGroups = [ "audio" ];
    };
  };
}

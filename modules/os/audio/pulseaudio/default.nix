{
  config,
  lib,
  ...
}:
let
  libcfg = lib.nixsys.os;

  mainUser = libcfg.getMainUser config;
  mainUserDefined = libcfg.isMainUserDefined config;

  cfg = config.nixsys.os.audio.pulseaudio;
in
{
  options.nixsys.os.audio.pulseaudio = {
    enable = lib.mkEnableOption "nixsys.os.audio.pulseaudio";
  };

  config = lib.mkIf cfg.enable {

    nixpkgs.config.pulseaudio = true;

    services.pipewire.enable = false;

    services.pulseaudio = {
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

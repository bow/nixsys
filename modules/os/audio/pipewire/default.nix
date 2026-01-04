{
  config,
  lib,
  ...
}:
let
  libcfg = lib.nixsys.os;

  mainUser = libcfg.getMainUser config;
  mainUserDefined = libcfg.isMainUserDefined config;

  cfg = config.nixsys.os.audio.pipewire;
in
{
  options.nixsys.os.audio.pipewire = {
    enable = lib.mkEnableOption "nixsys.os.audio.pipewire";
  };

  config = lib.mkIf cfg.enable {

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      extraConfig = {
        pipewire."99-silent-bell.conf" = {
          "context.properties" = {
            "module.x11.bell" = false;
          };
        };
      };
    };
    security.rtkit.enable = true;

    users.users = lib.mkIf mainUserDefined {
      ${mainUser.name}.extraGroups = [ "pipewire" ];
    };
  };
}

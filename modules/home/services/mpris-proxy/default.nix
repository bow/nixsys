{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  libcfg = lib.nixsys.home;

  audioEnabled = pulseaudioEnabled || pipewireEnabled;
  bluetoothEnabled = osConfig.nixsys.os.bluetooth.enable or false;
  pulseaudioEnabled = osConfig.nixsys.os.audio.pulseaudio.enable or false;
  pipewireEnabled = osConfig.nixsys.os.audio.pipewire.enable or false;

  desktopEnabled = libcfg.isDesktopEnabled config;

  cfg = config.nixsys.home.services.mpris-proxy;
in
{
  options.nixsys.home.services.mpris-proxy = {
    enable = lib.mkEnableOption "nixsys.home.services.mpris-proxy" // {
      default = bluetoothEnabled && desktopEnabled && audioEnabled;
    };
    package = lib.mkPackageOption pkgs "bluez" { };
  };

  config = lib.mkIf cfg.enable {
    services.mpris-proxy = {
      inherit (cfg) package;
      enable = true;
    };
  };
}

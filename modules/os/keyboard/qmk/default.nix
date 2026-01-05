{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixsys.os.keyboard.qmk;
in
{
  options.nixsys.os.keyboard.qmk = {
    enable = lib.mkEnableOption "nixsys.os.keyboard.qmk";
  };

  config = lib.mkIf cfg.enable {

    hardware.keyboard.qmk.enable = true;

    environment.systemPackages = [
      pkgs.qmk
      pkgs.via
    ];

    services.udev.packages =
      let
        qmk-local-pkg = pkgs.writeTextFile {
          name = "qmk-udev-rules";
          destination = "/etc/udev/rules.d/60-qmk-local.rules";
          text = ''
            # Keychron
            # V1 Max
            SUBSYSTEMS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0913", TAG+="uaccess"
            # Q1 Max
            SUBSYSTEMS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0810", TAG+="uaccess"
          '';
        };
      in
      [
        pkgs.qmk
        pkgs.qmk-udev-rules
        pkgs.qmk_hid
        pkgs.via
        qmk-local-pkg
      ];
  };
}

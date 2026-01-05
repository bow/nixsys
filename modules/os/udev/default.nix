{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixsys.os.udev;

  udevEnabled = cfg.rulesets.wake-on-device.enable;
in
{
  options.nixsys.os.udev = {
    rulesets = {
      wake-on-device.enable = lib.mkEnableOption "nixsys.os.udev.rulesets.wake-on-device";
    };
  };
  config = lib.mkIf udevEnabled {
    services = {
      udev = {
        enable = lib.mkDefault true;
        packages = lib.optional cfg.rulesets.wake-on-device.enable (
          pkgs.writeTextFile {
            name = "wake-on-device-udev-rules";
            destination = "/etc/udev/rules.d/50-wake-on-device.rules";
            text = ''
              # Logitech Unifying Receiver - Keyboard
              ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c52b", ATTR{power/wakeup}="enabled", ATTR{driver/4-1.1.3.1/power/wakeup}="enabled"

              # Keychron Link dongle on dock front
              ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d030", ATTR{power/wakeup}="enabled", ATTR{driver/4-1.1.3.4/power/wakeup}="enabled"
              # Keychron Link dongle on dock back
              ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d030", ATTR{power/wakeup}="enabled", ATTR{driver/4-1.1.3.3/power/wakeup}="enabled"

              # Keychron V1 Max cable on laptop
              ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0913", ATTR{power/wakeup}="enabled", ATTR{driver/6-1/power/wakeup}="enabled"
              # Keychron V1 Max cable on dock front
              ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0913", ATTR{power/wakeup}="enabled", ATTR{driver/4-1.1.1.4/power/wakeup}="enabled"

              # Keychron Q1 Max cable on laptop
              ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0810", ATTR{power/wakeup}="enabled", ATTR{driver/6-1/power/wakeup}="enabled"
              # Keychron Q1 Max cable on dock front
              ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0810", ATTR{power/wakeup}="enabled", ATTR{driver/4-1.1.1.4/power/wakeup}="enabled"

              # Logitech Unifiying Receiver - Mouse
              # ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c52b", ATTR{power/wakeup}="enabled", ATTR{driver/4-1.1.3.2/power/wakeup}="enabled"
            '';
          }
        );
      };
    };
  };
}

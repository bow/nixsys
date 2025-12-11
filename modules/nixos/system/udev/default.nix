{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixsys.system.udev;

  udevEnabled = cfg.rulesets.wake-on-device.enable || cfg.rulesets.qmk.enable;
in
{
  options.nixsys.system.udev = {
    rulesets = {
      wake-on-device.enable = lib.mkEnableOption "nixsys.system.udev.rulesets.wake-on-device";
      qmk.enable = lib.mkEnableOption "nixsys.system.udev.rulesets.qmk";
    };
  };
  config = lib.mkIf udevEnabled {
    services = {
      udev = {
        enable = lib.mkDefault true;
        packages =
          lib.optional cfg.rulesets.wake-on-device.enable (
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
          )
          ++ lib.optional cfg.rulesets.qmk.enable (
            pkgs.writeTextFile {
              name = "qmk-udev-rules";
              destination = "/etc/udev/rules.d/60-qmk.rules";
              text = ''
                # Keychron
                # V1 Max
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0913", TAG+="uaccess"
                # Q1 Max
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0810", TAG+="uaccess"

                # Atmel DFU
                ### ATmega16U2
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2fef", TAG+="uaccess"
                ### ATmega32U2
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff0", TAG+="uaccess"
                ### ATmega16U4
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff3", TAG+="uaccess"
                ### ATmega32U4
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff4", TAG+="uaccess"
                ### AT90USB64
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff9", TAG+="uaccess"
                ### AT90USB162
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ffa", TAG+="uaccess"
                ### AT90USB128
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ffb", TAG+="uaccess"

                # Input Club
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="1c11", ATTRS{idProduct}=="b007", TAG+="uaccess"

                # STM32duino
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="1eaf", ATTRS{idProduct}=="0003", TAG+="uaccess"
                # STM32 DFU
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"

                # BootloadHID
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05df", TAG+="uaccess"

                # USBAspLoader
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", TAG+="uaccess"

                # USBtinyISP
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="1782", ATTRS{idProduct}=="0c9f", TAG+="uaccess"

                # ModemManager should ignore the following devices
                # Atmel SAM-BA (Massdrop)
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="6124", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"

                # Caterina (Pro Micro)
                ## pid.codes shared PID
                ### Keyboardio Atreus 2 Bootloader
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2302", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
                ## Spark Fun Electronics
                ### Pro Micro 3V3/8MHz
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9203", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
                ### Pro Micro 5V/16MHz
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9205", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
                ### LilyPad 3V3/8MHz (and some Pro Micro clones)
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9207", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
                ## Pololu Electronics
                ### A-Star 32U4
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="1ffb", ATTRS{idProduct}=="0101", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
                ## Arduino SA
                ### Leonardo
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0036", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
                ### Micro
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0037", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
                ## Adafruit Industries LLC
                ### Feather 32U4
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="000c", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
                ### ItsyBitsy 32U4 3V3/8MHz
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="000d", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
                ### ItsyBitsy 32U4 5V/16MHz
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="000e", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
                ## dog hunter AG
                ### Leonardo
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="0036", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
                ### Micro
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="0037", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"

                # hid_listen
                KERNEL=="hidraw*", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"

                # hid bootloaders
                ## QMK HID
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2067", TAG+="uaccess"
                ## PJRC's HalfKay
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="0478", TAG+="uaccess"

                # APM32 DFU
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="314b", ATTRS{idProduct}=="0106", TAG+="uaccess"

                # GD32V DFU
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="28e9", ATTRS{idProduct}=="0189", TAG+="uaccess"

                # WB32 DFU
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="dfa0", TAG+="uaccess"
              '';
            }
          );
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.os;

  mainUser = libcfg.getMainUser config;
  mainUserDefined = libcfg.isMainUserDefined config;

  cfg = config.nixsys.os.virtualization.host.libvirtd;
in
{
  options.nixsys.os.virtualization.host.libvirtd = {
    enable = lib.mkEnableOption "nixsys.os.virtualization.host.libvirtd";
    package = lib.mkPackageOption pkgs "libvirt" { };

    qemu-package = lib.mkPackageOption pkgs "qemu" { };
    swtpm-package = lib.mkPackageOption pkgs "swtpm" { };
    virt-manager-package = lib.mkPackageOption pkgs "virt-manager" { };
    virtiofsd-package = lib.mkPackageOption pkgs "virtiofsd" { };

    start-delay = lib.mkOption {
      description = "Sets virtualisation.libvirtd.startDelay";
      type = types.ints.unsigned;
      default = 1;
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.dnsmasq
    ];

    programs.virt-manager = {
      enable = true;
      package = cfg.virt-manager-package;
    };

    systemd.tmpfiles.rules = [
      "L+ /var/lib/qemu/firmware - - - - ${cfg.qemu-package}/share/qemu/firmware"
    ];

    users.users = lib.mkIf mainUserDefined {
      ${mainUser.name}.extraGroups = [ "libvirtd" ];
    };

    virtualisation.libvirtd = {
      enable = true;

      inherit (cfg) package;
      allowedBridges = [ "virbr0" ];
      onShutdown = "suspend";
      sshProxy = true;
      startDelay = cfg.start-delay;
      qemu = {
        package = cfg.qemu-package;
        runAsRoot = true;
        swtpm = {
          enable = true;
          package = cfg.swtpm-package;
        };
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
  };
}

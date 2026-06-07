{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.nixsys) enabled enabledWith;

  cfg = config.nixsys.home.profile.base;
in
{
  options.nixsys.home.profile.base = {
    enable = lib.mkEnableOption "nixsys.home.profile.base";
  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      # Base.
      pkgs.coreutils
      pkgs.curl
      pkgs.file
      pkgs.fzf
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.jq
      pkgs.readline
      pkgs.ripgrep
      pkgs.which

      # Ops.
      pkgs.btop
      pkgs.dmidecode
      pkgs.dnsmasq
      pkgs.dnsutils
      pkgs.dua
      pkgs.duf
      pkgs.ethtool
      pkgs.eza
      pkgs.fd
      pkgs.findutils
      pkgs.hexyl
      pkgs.htop
      pkgs.iftop
      pkgs.inetutils
      pkgs.iotop
      pkgs.ipcalc
      pkgs.iperf3
      pkgs.iproute2
      pkgs.ldns
      pkgs.lshw
      pkgs.lsof
      pkgs.ltrace
      pkgs.mtr
      pkgs.nmap
      pkgs.ntfs3g
      pkgs.openssl
      pkgs.pciutils
      pkgs.pv
      pkgs.rsync
      pkgs.socat
      pkgs.strace
      pkgs.sysstat
      pkgs.tree
      pkgs.usbutils
      pkgs.whois

      # Compression tools.
      pkgs.gzip
      pkgs.lzip
      pkgs.p7zip
      pkgs.unrar
      pkgs.unzip
      pkgs.xz
      pkgs.zip
      pkgs.zstd

      # Security.
      pkgs.age
    ];

    nixsys.home = {
      programs = {
        neovim = enabledWith { extended = lib.mkDefault false; };
      };
    };
  };
}

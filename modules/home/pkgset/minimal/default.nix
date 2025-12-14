{
  config,
  lib,
  ...
}:
let
  inherit (lib.nixsys) enabled;

  cfg = config.nixsys.home.pkgset.minimal;
in
{
  options.nixsys.home.pkgset.minimal = {
    enable = lib.mkEnableOption "nixsys.home.pkgset.minimal";
  };
  config = lib.mkIf cfg.enable {

    nixsys.home = {

      programs = {
        # Base.
        coreutils = enabled;
        curl = enabled;
        file = enabled;
        gawk = enabled;
        gnugrep = enabled;
        gnused = enabled;
        jq = enabled;
        vim = enabled;
        which = enabled;

        # Ops.
        btop = enabled;
        dmidecode = enabled;
        dnsmasq = enabled;
        dua = enabled;
        duf = enabled;
        ethtool = enabled;
        eza = enabled;
        fd = enabled;
        findutils = enabled;
        hexyl = enabled;
        htop = enabled;
        iftop = enabled;
        inetutils = enabled;
        iotop = enabled;
        ipcalc = enabled;
        iperf3 = enabled;
        iproute2 = enabled;
        ldns = enabled;
        lshw = enabled;
        ltrace = enabled;
        mtr = enabled;
        nmap = enabled;
        ntfs3g = enabled;
        pciutils = enabled;
        pv = enabled;
        socat = enabled;
        strace = enabled;
        sysstat = enabled;
        tree = enabled;
        usbutils = enabled;
        whois = enabled;

        # Compression tools.
        gzip = enabled;
        lzip = enabled;
        p7zip = enabled;
        unrar = enabled;
        unzip = enabled;
        xz = enabled;
        zip = enabled;
        zstd = enabled;

        # Security.
        age = enabled;
        openssl = enabled;
      };
    };
  };
}

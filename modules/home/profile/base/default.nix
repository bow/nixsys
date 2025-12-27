{
  config,
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

    nixsys.home = {

      programs = {
        # Base.
        coreutils = enabled;
        curl = enabled;
        dircolors = enabled;
        file = enabled;
        fzf = enabled;
        gawk = enabled;
        gnugrep = enabled;
        gnused = enabled;
        jq = enabled;
        neovim = enabledWith { extended = lib.mkDefault false; };
        readline = enabled;
        ripgrep = enabled;
        which = enabled;

        # Ops.
        btop = enabled;
        dmidecode = enabled;
        dnsmasq = enabled;
        dnsutils = enabled;
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

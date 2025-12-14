{
  lib,
  ...
}:
let
  mkSuiteModule =
    suiteName: argsf:
    (
      {
        config,
        ...
      }:
      let
        inherit (config.nixsys.home) programs;
        mcfg = config.nixsys.home.suites.${suiteName};
      in
      {
        options.nixsys.home.suites.${suiteName} = {
          enable = lib.mkEnableOption "nixsys.home.suites.${suiteName}";
        };
        config = lib.mkIf mcfg.enable {
          nixsys.home.programs = builtins.mapAttrs (_progName: _progMod: { enable = true; }) (argsf programs);
        };
      }
    );

  mkSuiteModuleImports = lib.mapAttrsToList (suiteName: argsf: mkSuiteModule suiteName argsf);
in
{
  # mkSuiteModuleImports takes a suite name -> function attrset. The function takes 'programs'
  # as a parameter, because we want to delay config evaluation out of imports but still be able
  # to refer to the modules using non-strings. We use 'inherit' then, because that's the only
  # way to refer to program modules using their names automatically.
  imports = mkSuiteModuleImports {
    backup = programs: {
      inherit (programs)
        restic
        ;
    };
    base = programs: {
      inherit (programs)
        coreutils
        curl
        file
        gawk
        gnugrep
        gnused
        jq
        vim
        which
        ;
    };
    chat = programs: {
      inherit (programs)
        weechat
        ;
    };
    media-editors = programs: {
      inherit (programs)
        pdftk
        imagemagick
        ;
    };
    network-clients = programs: {
      inherit (programs)
        aria2
        elinks
        wget
        ;
    };
    ops = programs: {
      inherit (programs)
        btop
        dmidecode
        dnsmasq
        dua
        duf
        ethtool
        eza
        fd
        findutils
        hexyl
        htop
        iftop
        inetutils
        iotop
        ipcalc
        iperf3
        iproute2
        ldns
        lshw
        ltrace
        mtr
        nmap
        ntfs3g
        pciutils
        pv
        socat
        strace
        sysstat
        tree
        usbutils
        whois

        # Compression tools.
        gzip
        lzip
        p7zip
        unrar
        unzip
        xz
        zip
        zstd
        ;
    };
    security = programs: {
      inherit (programs)
        age
        gnupg
        openssl
        pass
        sequoia-sq
        ;
    };
    virtualization = programs: {
      inherit (programs)
        distrobox
        nerdctl
        packer
        virt-viewer
        ;
    };
  };
}

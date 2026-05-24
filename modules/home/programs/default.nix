{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;

  # This is for programs that we just want to put behind an enable / disable flag and
  # no other options.
  mkProgramModule =
    pkgName: pkg:
    (
      { config, ... }:
      let
        pcfg = config.nixsys.home.programs.${pkgName};
      in
      {
        options.nixsys.home.programs.${pkgName} = {
          enable = lib.mkEnableOption "nixsys.home.programs.${pkgName}";
          package = lib.mkOption {
            type = types.package;
            default = pkg;
          };
        };

        config = lib.mkIf pcfg.enable {
          home.packages = [ pcfg.package ];
        };
      }
    );

  mkProgramModuleImports = args: builtins.attrValues (builtins.mapAttrs mkProgramModule args);
in
{
  # 'inherit' because that's the only reliable way to map package names we use here to the actual
  # packages we want ~ without interference from env-wrapping or aliases.
  imports = mkProgramModuleImports {

    inherit (pkgs)
      # Backup tools.
      restic

      # Base tools.
      coreutils
      curl
      file
      gawk
      gnugrep
      gnused
      jq
      vim
      which

      # Chat.
      weechat

      # Media tools.
      pdftk
      chafa
      graphviz
      imagemagick
      timg

      # Network clients.
      aria2
      elinks
      rsync
      wget

      # Ops.
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
      lsof
      ltrace
      mtr
      nmap
      ntfs3g
      openssl
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
      # Encryption.
      age
      gnupg
      sequoia-sq

      # Presentation.
      presenterm

      # Virtualization.
      bubblewrap
      distrobox
      nerdctl
      packer
      virt-viewer

      # Writing.
      texliveFull

      # Desktop.
      arandr
      dbeaver-bin
      dropbox
      evince
      geany
      google-chrome
      gparted
      maim
      nomacs
      openconnect
      pavucontrol
      protonmail-bridge
      protonvpn-gui
      pwvucontrol
      slack
      snapper-gui
      solaar
      spotify
      sxiv
      thunderbird-latest
      todoist-electron
      veracrypt
      vlc
      ;

    inherit (pkgs.local) nxn;
  };
}

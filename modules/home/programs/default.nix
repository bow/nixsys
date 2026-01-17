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

      # Media editors.
      pdftk
      chafa
      imagemagick

      # Network clients.
      aria2
      elinks
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

      # Virtualization.
      distrobox
      nerdctl
      packer
      virt-viewer

      # Desktop.
      arandr
      btrfs-assistant
      dbeaver-bin
      dropbox
      evince
      geany
      google-chrome
      gparted
      maim
      nomacs
      obsidian
      openconnect
      pavucontrol
      protonmail-bridge
      pwvucontrol
      slack
      solaar
      spotify
      sxiv
      synology-drive-client
      thunderbird-latest
      todoist-electron
      veracrypt
      vlc
      ;
  };
}

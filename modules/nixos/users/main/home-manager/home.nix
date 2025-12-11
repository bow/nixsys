{
  config,
  lib,
  pkgs,
  outputs,
  user,
  asStandalone ? true,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.home;

  desktopEnabled = libcfg.isDesktopEnabled config;

  cliPackages = [
    pkgs.age
    pkgs.aria2
    pkgs.btop
    pkgs.coreutils-full
    pkgs.curl
    pkgs.curlie
    pkgs.distrobox
    pkgs.dmidecode
    pkgs.dnsmasq
    pkgs.dos2unix
    pkgs.dua
    pkgs.duf
    pkgs.elinks
    pkgs.entr
    pkgs.ethtool
    pkgs.eza
    pkgs.fd
    pkgs.file
    pkgs.findutils
    pkgs.gh
    pkgs.glow
    pkgs.gnugrep
    pkgs.gnupatch
    pkgs.gnupg
    pkgs.gnused
    pkgs.grpcurl
    pkgs.gzip
    pkgs.hexyl
    pkgs.htop
    pkgs.iftop
    pkgs.imagemagick
    pkgs.inetutils
    pkgs.iotop
    pkgs.ipcalc
    pkgs.iperf3
    pkgs.iproute2
    pkgs.jq
    pkgs.ldns
    pkgs.libvirt
    pkgs.lld
    pkgs.lldb
    pkgs.lshw
    pkgs.ltrace
    pkgs.lzip
    pkgs.minify
    pkgs.mtr
    pkgs.nerdctl
    pkgs.nh
    pkgs.nmap
    pkgs.ntfs3g
    pkgs.p7zip
    pkgs.packer
    pkgs.pass
    pkgs.pciutils
    pkgs.pdftk
    pkgs.pv
    pkgs.qemu
    pkgs.restic
    pkgs.sequoia-sq
    pkgs.socat
    pkgs.strace
    pkgs.sysstat
    pkgs.tmux
    pkgs.tree
    pkgs.unrar
    pkgs.unzip
    pkgs.usbutils
    pkgs.vim
    pkgs.virt-manager
    pkgs.virt-viewer
    pkgs.weechat
    pkgs.wget
    pkgs.which
    pkgs.whois
    pkgs.wrk
    pkgs.xan
    pkgs.xz
    pkgs.zip
    pkgs.zstd
  ];

  desktopPackages = [
    # File storage.
    pkgs.dropbox

    # PDF reader.
    pkgs.evince

    # Web browser.
    pkgs.firefox

    # Web browser.
    pkgs.google-chrome

    # Text editor.
    pkgs.geany

    # Disk partition editor.
    pkgs.gparted

    # Screnshot tool.
    pkgs.maim

    # Image viewer.
    pkgs.nomacs

    # Markdown-based knowledge base.
    pkgs.obsidian

    # Mail client.
    pkgs.protonmail-bridge

    # Music player.
    pkgs.spotify

    # Image viewer.
    pkgs.sxiv

    # Logitech peripherals.
    pkgs.solaar

    # Synology.
    pkgs.synology-drive-client

    # Email client.
    pkgs.thunderbird-latest

    # Official Todoist app.
    pkgs.todoist-electron

    # Encryption tooling.
    pkgs.veracrypt

    # Video player.
    pkgs.vlc

    # File explorer + plugins.
    pkgs.xfce.thunar
    pkgs.xfce.thunar-archive-plugin
    pkgs.xfce.thunar-dropbox-plugin
    pkgs.xfce.thunar-volman
  ];
in
{
  options.nixsys.home.system = lib.mkOption {
    default = { };
    description = "Container for copied system-level settings";
    # Make this a typed submodule to prevent this from becoming a random bag of stuff.
    type = types.submodule {
      options = {
        bluetooth.enable = lib.mkEnableOption "nixsys.home.system.bluetooth";
        docker.enable = lib.mkEnableOption "nixsys.home.system.docker";
        libvirtd.enable = lib.mkEnableOption "nixsys.home.system.libvirtd";
        pulseaudio.enable = lib.mkEnableOption "nixsys.home.system.pulseaudio";
      };
    };
  };

  config = {
    home = {
      stateVersion = "25.05";
      username = user.name;
      homeDirectory = user.home-directory;
      packages = cliPackages ++ (lib.optionals desktopEnabled desktopPackages);
      preferXdgDirectories = true;

      # FIXME: Find out where to best put this.
      file.".config/libvirt/qemu.conf" = lib.mkIf config.nixsys.home.system.libvirtd.enable {
        text = ''
          nvram = [
            "/run/libvirt/nix-ovmf/edk2-aarch64-code.fd:/run/libvirt/nix-ovmf/edk2-arm-vars.fd",
            "/run/libvirt/nix-ovmf/edk2-x86_64-code.fd:/run/libvirt/nix-ovmf/edk2-i386-vars.fd"
          ]
        '';
      };
    };

    nixpkgs = lib.mkIf asStandalone {
      overlays = builtins.attrValues outputs.overlays;
      config.allowUnfree = true;
    };

    programs = {
      home-manager.enable = true;
    };

    # Reload systemd units on config change.
    systemd.user.startServices = "sd-switch";
  };
}

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

  tools = {
    backup = [
      pkgs.restic
    ];
    base = [
      pkgs.coreutils
      pkgs.curl
      pkgs.file
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.jq
      pkgs.vim
      pkgs.which
    ];
    chat = [
      pkgs.weechat
    ];
    dev = [
      pkgs.curlie
      pkgs.dos2unix
      pkgs.entr
      pkgs.glow
      pkgs.gnumake
      pkgs.gnupatch
      pkgs.grpcurl
      pkgs.minify
      pkgs.wrk
      pkgs.xan
    ];
    format-editors = [
      pkgs.pdftk
      pkgs.imagemagick
    ];
    network-clients = [
      pkgs.aria2
      pkgs.elinks
      pkgs.wget
    ];
    nix = [
      pkgs.nh
    ];
    ops = [
      pkgs.btop
      pkgs.dmidecode
      pkgs.dnsmasq
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
      pkgs.ltrace
      pkgs.mtr
      pkgs.nmap
      pkgs.ntfs3g
      pkgs.pciutils
      pkgs.pv
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
    ];
    security = [
      pkgs.age
      pkgs.gnupg
      pkgs.openssl
      pkgs.pass
      pkgs.sequoia-sq
    ];
    virtualization = [
      pkgs.distrobox
      pkgs.nerdctl
      pkgs.packer
      pkgs.virt-viewer
    ];
  };

  cliPackages =
    tools.backup
    ++ tools.base
    ++ tools.chat
    ++ tools.dev
    ++ tools.format-editors
    ++ tools.network-clients
    ++ tools.nix
    ++ tools.ops
    ++ tools.security
    ++ tools.virtualization;

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

    # VPN client.
    pkgs.openconnect

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

_: rec {
  /**
    Return the package used by the given module.
  */
  getModulePackage = modName: config: config.nixsys.home.programs.${modName}.package;

  /**
    Return the package used by the fzf module.
  */
  getFzfPackage = getModulePackage "fzf";

  /**
    Return the package used by the ghostty module.
  */
  getGhosttyPackage = getModulePackage "ghostty";

  /**
    Return the package used by the gpg module.
  */
  getGpgPackage = getModulePackage "gpg";

  /**
    Return the package used by the neovim module.
  */
  getNeovimPackage = getModulePackage "neovim";

  /**
    Return the package used by the ripgrep module.
  */
  getRipgrepPackage = getModulePackage "ripgrep";

  /**
    Return whether the current config enables i3.
  */
  isI3Enabled = config: config.nixsys.home.desktop.i3.enable;
  /**
    Return the package used by the ripgrep module.
  */
  getI3Package = config: config.nixsys.home.desktop.i3.package;

  /**
    Return whether the current config enables Xorg.
  */
  isXorgEnabled = isI3Enabled;

  /**
    Return whether the current config enables desktop.
  */
  isDesktopEnabled = isXorgEnabled;

  /**
    Return whether a os-set attribute with the given name exists
    and is set to enabled.
  */
  isOSAttrEnabled =
    attrName: config:
    let
      osAttrs = config.nixsys.home.os;
    in
    builtins.hasAttr attrName osAttrs && osAttrs.${attrName}.enable;

  /**
    Return whether the current config enables btrfs.
  */
  isBTRFSEnabled = isOSAttrEnabled "btrfs";

  /**
    Return whether the current config enables docker.
  */
  isDockerEnabled = isOSAttrEnabled "docker";

  /**
    Return whether the current config enables pulseaudio.
  */
  isPulseaudioEnabled = isOSAttrEnabled "pulseaudio";

  /**
    Return whether the current config enables pipewire.
  */
  isPipewireEnabled = isOSAttrEnabled "pipewire";

  /**
    Return whether the current config enables bluetooth.
  */
  isBluetoothEnabled = isOSAttrEnabled "bluetooth";

  /**
    Return whether the current config enables audio.
  */
  isAudioEnabled = config: isPipewireEnabled config || isPulseaudioEnabled config;

  /**
    Return whether the current config enables the given program.
  */
  isProgramEnabled = progName: config: config.nixsys.home.programs.${progName}.enable;

  /**
    Return whether the current config enables bat.
  */
  isBatEnabled = isProgramEnabled "bat";

  /**
    Return whether the current config enables fzf.
  */
  isFzfEnabled = isProgramEnabled "fzf";

  /**
    Return whether the current config enables ghostty.
  */
  isGhosttyEnabled = isProgramEnabled "ghostty";

  /**
    Return whether the current config enables gpg.
  */
  isGpgEnabled = isProgramEnabled "gpg";

  /**
    Return whether the current config enables neovim.
  */
  isNeovimEnabled = isProgramEnabled "neovim";

  /**
    Return whether the current config enables ripgrep.
  */
  isRipgrepEnabled = isProgramEnabled "ripgrep";

  /**
    Return whether the current config enables rofi.
  */
  isRofiEnabled = isProgramEnabled "rofi";

  /**
    Return whether the current config enables zoxide.
  */
  isZoxideEnabled = isProgramEnabled "zoxide";

  /**
    Return whether the current user enables a bash shell.
  */
  isShellBash = user: user.shell == "bash";
}

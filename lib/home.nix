_: rec {
  /**
    Return the package used by the given module.
  */
  getModulePackage = config: name: config.nixsys.home.programs.${name}.package;

  /**
    Return the package used by the fzf module.
  */
  getFzfPackage = config: getModulePackage config "fzf";

  /**
    Return the package used by the neovim module.
  */
  getNeovimPackage = config: getModulePackage config "neovim";

  /**
    Return the package used by the ripgrep module.
  */
  getRipgrepPackage = config: getModulePackage config "ripgrep";

  /**
    Return whether the current config enables i3.
  */
  isI3Enabled = config: config.nixsys.home.desktop.i3.enable;

  /**
    Return whether the current config enables Xorg.
  */
  isXorgEnabled = isI3Enabled;

  /**
    Return whether the current config enables desktop.
  */
  isDesktopEnabled = isXorgEnabled;

  /**
    Return whether the current config enables docker.
  */
  isDockerEnabled =
    config:
    let
      sys = config.nixsys.home.system;
    in
    sys != { } && sys.docker.enable;

  /**
    Return whether the current config enables audio.
  */
  isPulseaudioEnabled =
    config:
    let
      sys = config.nixsys.home.system;
    in
    sys != { } && sys.pulseaudio.enable;

  /**
    Return whether the current config enables the given program.
  */
  isProgramEnabled = config: name: config.nixsys.home.programs.${name}.enable;

  /**
    Return whether the current config enables bat.
  */
  isBatEnabled = config: isProgramEnabled config "bat";

  /**
    Return whether the current config enables fzf.
  */
  isFzfEnabled = config: isProgramEnabled config "fzf";

  /**
    Return whether the current config enables ghostty.
  */
  isGhosttyEnabled = config: isProgramEnabled config "ghostty";

  /**
    Return whether the current config enables neovim.
  */
  isNeovimEnabled = config: isProgramEnabled config "neovim";

  /**
    Return whether the current config enables ripgrep.
  */
  isRipgrepEnabled = config: isProgramEnabled config "ripgrep";

  /**
    Return whether the current config enables rofi.
  */
  isRofiEnabled = config: isProgramEnabled config "rofi";

  /**
    Return whether the current config enables zoxide.
  */
  isZoxideEnabled = config: isProgramEnabled config "zoxide";

  /**
    Return whether the current user enables a bash shell.
  */
  isShellBash = user: user.shell == "bash";
}

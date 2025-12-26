_: rec {
  /**
    Return the system hostname. If it is null, an error will be thrown.
  */
  getHostName =
    config:
    let
      name = config.nixsys.os.hostname;
    in
    if name == null then throw "nixsys.os.hostname is undefined" else name;

  /**
    Return the main user. Throw an error if the name is null.
  */
  getMainUser =
    config:
    let
      user = config.nixsys.os.users.main;
    in
    if user.name == null then throw "nixsys.os.users.main.name is undefined" else user;

  /**
    Return the main user if its name is not null. Otherwise return null.
  */
  getMainUserOrNull =
    config:
    let
      user = config.nixsys.os.users.main;
    in
    if user.name == null then null else user;

  /**
    Return the name of the main user. If it is null, an error will be thrown.
  */
  getMainUserName = config: (getMainUser config).name;

  /**
    Return whether this config defines main user or not.
  */
  isMainUserDefined = config: config.nixsys.os.users.main.name != null;

  /**
    Return whether the current config enables the BTRFS filesystem.
  */
  isBTRFSEnabled =
    config:
    let
      fs = config.boot.supportedFilesystems;
    in
    builtins.hasAttr "btrfs" fs && fs.btrfs;

  /**
    Return whether the current config enables i3.
  */
  isI3Enabled = config: config.nixsys.os.users.main.session.i3.enable;

  /**
    Return whether the current config enables Xorg.
  */
  isXorgEnabled = isI3Enabled;

  /**
    Return whether the current config enables a desktop.
  */
  isDesktopEnabled = isXorgEnabled;

  /**
    Return the nixsys home-manager config if it is enabled and a main user is defined,
    otherwise return null.
  */
  getHomeConfigOrNull =
    config:
    let
      mainUser = getMainUserOrNull config;
    in
    if mainUser != null && mainUser.home-manager.enable then
      config.home-manager.users.${mainUser.name}.nixsys.home
    else
      null;
}

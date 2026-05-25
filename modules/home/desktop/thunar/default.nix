{
  lib,
  osConfig,
  ...
}:
{
  xdg.mimeApps = lib.optionalAttrs (osConfig != null) {
    enable = lib.mkDefault true;
    defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
    };
  };
}

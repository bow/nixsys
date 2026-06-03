{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.nixsys.os.enable {
    environment = {
      pathsToLink = [
        "/share/bash-completion"

        # FIXME: Link only when HM XDG is enabled.
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
      defaultPackages = [ ];

      systemPackages = [
        pkgs.coreutils-full
        pkgs.curl
        pkgs.findutils
        pkgs.file
        pkgs.gawk
        pkgs.gnugrep
        pkgs.gnused
        pkgs.gnutar
        pkgs.gzip
        pkgs.htop
        pkgs.iputils
        pkgs.iotop
        pkgs.jq
        pkgs.neovim
        pkgs.readline
        pkgs.ripgrep
        pkgs.rsync
        pkgs.strace
        pkgs.unzip
        pkgs.zip
        pkgs.zstd
      ];
      variables = {
        EDITOR = "nvim";
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.nixsys.enable {
    environment = {
      pathsToLink = [ "/share/bash-completion" ];
      systemPackages = [
        pkgs.curl
        pkgs.findutils
        pkgs.file
        pkgs.git
        pkgs.gnugrep
        pkgs.gnupg
        pkgs.gnused
        pkgs.iputils
        pkgs.jq
        pkgs.neovim
        pkgs.readline
        pkgs.unzip
        pkgs.vim
        pkgs.wget

        pkgs.unstable.ripgrep
      ];
      variables = {
        EDITOR = "nvim";
      };
    };
  };
}

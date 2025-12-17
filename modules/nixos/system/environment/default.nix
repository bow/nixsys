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
        pkgs.coreutils-full
        pkgs.findutils
        pkgs.file
        pkgs.gawk
        pkgs.gnugrep
        pkgs.gnused
        pkgs.gzip
        pkgs.htop
        pkgs.iputils
        pkgs.iotop
        pkgs.jq
        pkgs.lzip
        pkgs.neovim
        pkgs.p7zip
        pkgs.readline
        pkgs.ripgrep
        pkgs.unzip
        pkgs.xz
        pkgs.zip
        pkgs.zstd
      ];
      variables = {
        EDITOR = "nvim";
      };
    };
  };
}

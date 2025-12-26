{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  libcfg = lib.nixsys.home;

  shellBash = libcfg.isShellBash user;

  cfg = config.nixsys.home.programs.nh;
in
{
  options.nixsys.home.programs.nh = {
    enable = lib.mkEnableOption "nixsys.home.programs.nh";
    package = lib.mkPackageOption pkgs.unstable "nh" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    programs.bash.bashrcExtra = lib.optionalString shellBash ''
      alias nhance='${cfg.package}/bin/nh os switch -u -d auto ${user.home-directory}/.nixcfg#nixosConfigurations.$(${pkgs.inetutils}/bin/hostname)'
    '';
  };
}

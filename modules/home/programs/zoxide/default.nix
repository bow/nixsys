{
  config,
  lib,
  user,
  ...
}:
let
  libcfg = lib.nixsys.home;

  shellBash = libcfg.isShellBash user;

  cfg = config.nixsys.home.programs.zoxide;
in
{
  options.nixsys.home.programs.zoxide = {
    enable = lib.mkEnableOption "nixsys.home.programs.zoxide";
  };

  config = lib.mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = shellBash;
      options = [ "--cmd j" ];
    };
  };
}

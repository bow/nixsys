{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixsys.home.programs.dnsutils;
in
{
  options.nixsys.home.programs.dnsutils = {
    enable = lib.mkEnableOption "nixsys.home.programs.dnsutils";
    package = lib.mkPackageOption pkgs "dnsutils" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file = {
      ".digrc" = {
        text = ''
          +noall +answer
        '';
      };
    };
  };
}

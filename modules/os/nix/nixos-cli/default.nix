{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.nixsys.os.nix.nixos-cli;
in
{
  imports = [
    inputs.nixos-cli.nixosModules.nixos-cli
  ];

  options.nixsys.os.nix.nixos-cli = {
    enable = lib.mkEnableOption "Enable nixos-cli module";
  };

  config = lib.mkIf cfg.enable {
    services.nixos-cli = {
      enable = true;
    };
  };
}

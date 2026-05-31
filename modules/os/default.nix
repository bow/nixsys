{
  lib,
  ...
}:
let
  inherit (lib) types;
in
{
  options.nixsys.os = {
    enable = lib.mkEnableOption "nixsys.os";
    hostname = lib.mkOption {
      type = types.str;
    };
    machine-data-dir = lib.mkOption {
      description = "Path to directory containing machine data to be snapshotted";
      type = types.str;
      default = "/kp";
    };
  };
}

{
  lib,
  user,
  ...
}:
let
  shellBash = user.shell == "bash";
in
{
  config = lib.mkIf shellBash {
    programs.bash = {
      vteIntegration = true;
    };
  };
}

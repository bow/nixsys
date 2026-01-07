{
  inputs,
  ...
}:
let
  # Permanent modifications.
  modificationsCommon = _final: prev: {
    # To speed up builds.
    rustup = prev.rustup.overrideAttrs (_: {
      doCheck = false;
    });
    terraform = prev.terraform.overrideAttrs (_: {
      doCheck = false;
    });
  };

  # Temporary fixes.
  fixesUnstable = _final: _prev: { };
in
{
  additions = final: prev: {
    local = import ../packages { pkgs = final; };
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev.stdenv.hostPlatform) system;
      config.allowUnfree = true;

      overlays = [
        modificationsCommon
        fixesUnstable
      ];
    };
  };

  modifications = modificationsCommon;
}

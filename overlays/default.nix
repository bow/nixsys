{
  inputs,
  ...
}:
{
  additions = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev.stdenv.hostPlatform) system;
      config.allowUnfree = true;

      overlays = [
        (final: prev: {
          polybar =
            let
              patch = final.fetchpatch {
                name = "gcc15-cstdint-fix.patch";
                url = "https://github.com/polybar/polybar/commit/f99e0b1c7a5b094f5a04b14101899d0cb4ece69d.patch";
                sha256 = "sha256-Mf9R4u1Kq4yqLqTFD5ZoLjrK+GmlvtSsEyRFRCiQ72U=";
              };
            in
            prev.polybar.overrideAttrs (old: {
              patches = old.patches ++ [ patch ];
            });
        })
      ];
    };
    local = import ../packages { pkgs = final; };
  };

  # Permanent modifications.
  modifications = _final: prev: {
    # To speed up builds.
    rustup = prev.rustup.overrideAttrs (_: {
      doCheck = false;
    });
    terraform = prev.terraform.overrideAttrs (_: {
      doCheck = false;
    });
    unstable = prev.unstable // {
      rustup = prev.unstable.rustup.overrideAttrs (_: {
        doCheck = false;
      });
      terraform = prev.unstable.terraform.overrideAttrs (_: {
        doCheck = false;
      });
    };
  };
}

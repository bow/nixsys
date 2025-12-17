{
  inputs,
  ...
}:
{
  additions = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
    local = import ../packages { pkgs = final; };
  };

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

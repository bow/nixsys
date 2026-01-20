{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
let
  inherit (lib) types;
  libcfg = lib.nixsys.os;

  hostName = libcfg.getHostName config;
  mainUserOrNull = libcfg.getMainUserOrNull config;

  cfg = config.nixsys.os.nix;
in
{
  options.nixsys.os.nix = {
    download-buffer-size = lib.mkOption {
      type = types.ints.positive;
      default = 134217728; # 128 MiB
      description = "Sets nix.settings.download-buffer-size";
    };
    gc-max-retention-days = lib.mkOption {
      type = types.ints.positive;
      default = 30;
      description = "The age of the oldest item to keep (in days) after garbage collection";
    };
    gc-min-free-space = lib.mkOption {
      type = types.ints.positive;
      default = 1073741824; # 1 GiB
      description = "Sets nix.settings.min-free";
    };
    flake-location = lib.mkOption {
      type = types.nullOr types.str;
      default = if mainUserOrNull != null then "${mainUserOrNull.home-directory}/.nixcfg" else null;
    };
  };

  config = lib.mkIf config.nixsys.os.enable {
    environment = {
      etc."nix/path/nixpkgs".source = inputs.nixpkgs;
      sessionVariables = lib.optionalAttrs (cfg.flake-location != null) {
        NIXOS_CONFIG = "${cfg.flake-location}#${hostName}";
      };
      systemPackages = [
        pkgs.nix-output-monitor
        pkgs.nvd
      ];
    };

    nix = {
      channel.enable = false;
      nixPath = [ "/etc/nix/path" ];
      registry.nixpkgs.flake = inputs.nixpkgs;

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than ${builtins.toString cfg.gc-max-retention-days}d";
      };

      settings = {
        auto-optimise-store = true;
        inherit (cfg) download-buffer-size;
        experimental-features = [
          "ca-derivations" # content-addressed derivations.
          "flakes" # nix flakes.
          "nix-command" # new nix subcommands.
        ];
        max-jobs = "auto";
        min-free = cfg.gc-min-free-space;
      };
    };

    nixpkgs = {
      overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
      ];
      config.allowUnfree = true;
    };

    programs.nix-ld = {
      enable = true;
    };

    services.nixos-cli = {
      enable = true;
      config = {
        use_nvd = true;
        aliases = {
          g = [ "generation" ];
          gd = [
            "generation"
            "diff"
          ];
          gl = [
            "generation"
            "list"
          ];
          glt = [
            "generation"
            "list"
            "--table"
          ];
        };
        apply = {
          use_nom = true;
        };
      };
    };
  };
}

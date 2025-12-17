{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;

  cfg = config.nixsys.home.programs.firefox;
in
{
  options.nixsys.home.programs.firefox = {
    enable = lib.mkEnableOption "nixsys.home.programs.firefox";
    package = lib.mkPackageOption pkgs.unstable "firefox" { };

    containers = lib.mkOption {
      type = types.attrs;
      default = { };
    };

    extra-search-engines = lib.mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {

    home.sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
    };

    programs.firefox = {
      enable = true;
      languagePacks = [
        "da"
        "en-US"
        "id"
        "nl"
      ];
      policies = {
        AllowFileSelectionDialogs = true;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        BlockAboutAddons = false;
        BlockAboutConfig = false;
        BlockAboutProfiles = false;
        BlockAboutSupport = false;
        BrowserDataBackup = {
          AllowBackup = true;
          AllowRestore = true;
        };
        CaptivePortal = true;
        Cookies = {
          Behavior = "reject-tracker";
          BehaviorPrivateBrowsing = "reject";
        };
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        DisableMasterPasswordCreation = true;
        DisablePocket = true;
        DisableSetDesktopBackground = true;
        DisableTelemetry = true;
        DisplayMenuBar = "default-off";
        # FIXME: Update XDG to allow for per-directory configuration and use here.
        DownloadDirectory = "${config.home.homeDirectory}/dl";
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        FirefoxHome = {
          Search = true;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          Stories = false;
          SponsoredPocket = false;
          SponsoredStories = false;
          Snippets = false;
        };
        GenerativeAI = {
          Enabled = false;
        };
        Homepage = {
          StartPage = "none";
        };
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        SearchBar = "unified";
        ShowHomeButton = false;
      };
      profiles = {
        user = {
          inherit (cfg) containers;
          id = 0;
          isDefault = true;
          search.engines = {
            "Nix Packages" = {
              definedAliases = [ "@np" ];
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            };

            "Home-Manager Options" = {
              definedAliases = [ "@hm" ];
              urls = [
                {
                  template = "https://home-manager-options.extranix.com/?query=yubico";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            };

            "NixOS Options" = {
              definedAliases = [ "@no" ];
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            };
          }
          // cfg.extra-search-engines;
        };
      };
    };
  };
}

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

    bookmarks = lib.mkOption {
      type = types.listOf (types.either types.attrs types.str);
      default = [ ];
    };

    containers = lib.mkOption {
      type = types.attrs;
      default = { };
    };

    default-browser = lib.mkOption {
      type = types.bool;
      default = true;
    };

    dev-pixels-per-px = lib.mkOption {
      type = types.float;
      default = 1.0;
    };

    extra-extensions = lib.mkOption {
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
    }
    // lib.optionalAttrs cfg.default-browser {
      BROWSER = "firefox";
    };

    xdg.mimeApps =
      let
        mimeTypes = [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/about"
          "x-scheme-handler/unknown"
        ];
      in
      lib.mkIf cfg.default-browser {
        enable = true;
        defaultApplications = builtins.listToAttrs (
          builtins.map (name: {
            inherit name;
            value = [ "firefox.desktop" ];
          }) mimeTypes
        );
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
          BehaviorPrivateBrowsing = "reject-tracker-and-partition-foreign";
        };
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        DisableMasterPasswordCreation = true;
        DisablePocket = true;
        DisableSetDesktopBackground = true;
        DisableTelemetry = true;
        DisplayMenuBar = "default-off";
        DontCheckDefaultBrowser = true;
        # FIXME: Update XDG to allow for per-directory configuration and use here.
        DownloadDirectory = "${config.home.homeDirectory}/dl";
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        ExtensionSettings = lib.recursiveUpdate {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "normal_installed";
          };
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "normal_installed";
          };
        } cfg.extra-extensions;
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
          StartPage = "startpage";
        };
        OfferToSaveLogins = false;
        SearchBar = "unified";
        ShowHomeButton = false;
      }
      // lib.optionalAttrs (cfg.bookmarks == [ ]) {
        NoDefaultBookmarks = true;
      };
      profiles = {
        user = {
          inherit (cfg) containers;
          bookmarks = lib.mkIf (cfg.bookmarks != [ ]) {
            force = true;
            settings = cfg.bookmarks;
          };
          id = 0;
          isDefault = true;
          search = {
            force = true;
            engines = {
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
                    template = "https://home-manager-options.extranix.com/";
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

              "Noogle" = {
                definedAliases = [ "@nf" ];
                urls = [
                  {
                    template = "https://noogle.dev/q";
                    params = [
                      {
                        name = "term";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };

              "Nixhub" = {
                definedAliases = [ "@nh" ];
                urls = [
                  {
                    template = "https://www.nixhub.io/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };
            }
            // cfg.extra-search-engines;

          };
          settings = {
            "browser.toolbars.bookmarks.visibility" = "never";
            "browser.translations.neverTranslateLanguages" = lib.concatStringsSep "," [
              "da"
              "de"
              "fr"
              "id"
              "ja"
              "nl"
            ];
            "browser.uiCustomization.state" = builtins.toJSON {
              placements = {
                widget-overflow-fixed-list = [
                  "save-to-pocket-button"
                  "fxa-toolbar-menu-button"
                ];
                unified-extensions-area = [
                  "ublock0_raymondhill_net-browser-action"
                  "jid1-mnnxcxisbpnsxq_jetpack-browser-action"
                ];
                nav-bar = [
                  "back-button"
                  "forward-button"
                  "stop-reload-button"
                  "developer-button"
                  "vertical-spacer"
                  "urlbar-container"
                  "downloads-button"
                  "unified-extensions-button"
                ];
                toolbar-menubar = [
                  "menubar-items"
                ];
                TabsToolbar = [
                  "firefox-view-button"
                  "tabbrowser-tabs"
                  "new-tab-button"
                  "alltabs-button"
                ];
                vertical-tabs = [ ];
                PersonalToolbar = [
                  "personal-bookmarks"
                ];
              };
              seen = [
                "save-to-pocket-button"
                "developer-button"
                "screenshot-button"
                "jid1-mnnxcxisbpnsxq_jetpack-browser-action"
                "ublock0_raymondhill_net-browser-action"
              ];
              dirtyAreaCache = [
                "nav-bar"
                "vertical-tabs"
                "PersonalToolbar"
                "toolbar-menubar"
                "TabsToolbar"
                "widget-overflow-fixed-list"
                "unified-extensions-area"
              ];
              currentVersion = 23;
              newElementCount = 4;
            };
            "general.smoothScroll.msdPhysics.enabled" = true;
            "general.smoothScroll.mouseWheel.duration.MinMS" = 200;
            "general.smoothScroll.mouseWheel.duration.MaxMS" = 400;
            "general.autoScroll" = true;
            "layout.css.devPixelsPerPx" = cfg.dev-pixels-per-px;
            "mousewheel.min_line_scroll_amount" = 50;
          };
        };
      };
    };
  };
}

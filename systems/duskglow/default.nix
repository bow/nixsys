{
  lib,
  user,
  hostname,
  ...
}:
let
  inherit (lib.nixsys) enabled enabledWith;
in
{
  nixsys = enabledWith {
    system = {
      inherit hostname;
      bluetooth = enabled;
      boot.systemd = enabled;
      networking.networkmanager = enabled;
      nix.nixos-cli = enabled;
      touchpad = enabled;
      udev.rulesets = {
        qmk = enabled;
        wake-on-device = enabled;
      };
      virtualization.host = {
        docker = enabled;
        libvirtd = enabled;
      };
    };
    users.main = {
      inherit (user)
        name
        full-name
        email
        location
        timezone
        ;
      trusted = true;
      session.greetd = enabledWith {
        settings.auto-login = true;
      };
      home-manager = enabledWith {
        desktop = {
          i3 = enabled;
          xdg = enabled;
        };
        devel = enabled;
        fonts = enabled;
        pkgset.home = enabled;
        programs = {
          bat = enabled;
          dircolors = enabled;
          direnv = enabled;
          dnsutils = enabled;
          fzf = enabled;
          git = enabled;
          gpg = enabled;
          ncmpcpp = enabled;
          neovim = enabled;
          readline = enabled;
          ripgrep = enabled;
          starship = enabled;
          tmux = enabled;
          yazi = enabled;
          zoxide = enabled;
        };
        services = {
          mpd = enabled;
          mpris-proxy = enabled;
          redshift = enabled;
        };
        theme.current = enabled;
      };
    };
  };

  system.stateVersion = "25.05";
}

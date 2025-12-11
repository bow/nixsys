_:
{
  nixsys = {
    system = {
      servers.ssh.enable = true;
      virtualization.guest = {
        enable = true;
        type = "qemu";
      };
    };
    users.main = {
      home-manager = {
        enable = true;
        desktop.i3 = {
          enable = true;
          mod-key = "Mod1";
        };
      };
    };
  };
}


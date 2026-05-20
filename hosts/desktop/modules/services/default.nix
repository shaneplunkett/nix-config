{ ... }:
{

  imports = [

    ./greetd.nix

  ];

  services = {
    xserver.videoDrivers = [ "amdgpu" ];
    flatpak.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    tailscale.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  users.users.shane.openssh.authorizedKeys.keyFiles = [ ../../../../authorized-keys ];
  security.sudo.extraRules = [
    {
      users = [ "shane" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/nix/store/*-nixos-system-*/bin/switch-to-configuration";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
        {
          command = "/run/current-system/sw/bin/env PATH=* NIX_PATH=* USER=shane LOCALE_ARCHIVE=* /nix/store/*-nixos-system-*/bin/switch-to-configuration *";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
        {
          command = "/run/current-system/sw/bin/nix-env -p /nix/var/nix/profiles/system --set *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

}

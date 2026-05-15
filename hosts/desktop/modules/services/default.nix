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

  # Passwordless sudo for nixos-rebuild (allows Claude Code to switch)
  security.sudo.extraRules = [
    {
      users = [ "shane" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

}

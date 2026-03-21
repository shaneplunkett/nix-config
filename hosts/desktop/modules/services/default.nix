{ ... }:
{

  imports = [

    ./greetd.nix

  ];

  services.xserver.videoDrivers = [ "amdgpu" ];
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.tailscale.enable = true;

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

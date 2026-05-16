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

  # Passwordless sudo for system activation — lets Claude Code complete
  # `nh os switch` without prompting. Three rules because nh doesn't shell
  # out to `nixos-rebuild`; it invokes the activation script directly and
  # then sets the system profile:
  #
  #   sudo /nix/store/<hash>-nixos-system-*/bin/switch-to-configuration switch
  #   sudo nix-env -p /nix/var/nix/profiles/system --set /nix/store/<hash>-...
  #
  # The first command is the old `nixos-rebuild` fallback in case anything
  # still reaches for it. SETENV on the activation script so nh can pass
  # NIXOS_INSTALL_BOOTLOADER / LOCALE_ARCHIVE through.
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
          command = "/run/current-system/sw/bin/nix-env -p /nix/var/nix/profiles/system --set *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

}

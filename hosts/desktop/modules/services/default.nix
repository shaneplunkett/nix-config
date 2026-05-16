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
  # `nh os switch` (and the legacy `nixos-rebuild switch` fallback) without
  # prompting.
  #
  # nh's actual invocation (verified via `nh os switch -v`):
  #   /run/wrappers/bin/sudo env PATH=<long> \
  #     NIX_PATH=<...> USER=shane LOCALE_ARCHIVE=<...> \
  #     /nix/store/<hash>-nixos-system-<host>-<ver>/bin/switch-to-configuration <action>
  #
  # From sudo's POV argv[0] is `env`, not the activation script — so a rule
  # matching switch-to-configuration alone never fires. The env-prefixed
  # entry below is what nh actually needs. Action verb `*` covers
  # switch/boot/test/dry-activate. SETENV on every rule so nh can pass
  # NIXOS_INSTALL_BOOTLOADER and friends through.
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

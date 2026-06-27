_: {

  users.users.shane = {
    isNormalUser = true;
    description = "Shane Plunkett";
    extraGroups = [
      "docker"
      "networkmanager"
      "dialout"
      "wheel"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "shane" ];
      commands = [
        {
          command = "/nix/store/*-nixos-system-*/bin/switch-to-configuration boot";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/nix/store/*-nixos-system-*/bin/switch-to-configuration test";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/nix/store/*-nixos-system-*/bin/switch-to-configuration switch";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/env * /nix/store/*-nixos-system-*/bin/switch-to-configuration test";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/env * /nix/store/*-nixos-system-*/bin/switch-to-configuration switch";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/env * /nix/store/*-nixos-system-*/bin/switch-to-configuration boot";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/env * nix build --no-link --profile /nix/var/nix/profiles/system /nix/store/*-nixos-system-*";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/env * ln -sfn /nix/var/nix/profiles/system-*-link /nix/var/nix/profiles/system";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}

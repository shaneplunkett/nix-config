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
          command = "/nix/store/*-nixos-system-*/bin/switch-to-configuration switch";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

}

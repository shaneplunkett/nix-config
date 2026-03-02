{ ... }:
{

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

}

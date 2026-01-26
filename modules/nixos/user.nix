{ ... }:
{

  users.users.shane = {
    isNormalUser = true;
    description = "Shane Plunkett";
    extraGroups = [
      "networkmanager"
      "dialout"
      "wheel"
    ];
  };

}

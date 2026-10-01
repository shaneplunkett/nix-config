{ ... }:

{
  imports = [
    ../../modules/base
    ../../modules/server
  ];

  power.sleep = {
    computer = "never";
  };

  system.stateVersion = 6;
}

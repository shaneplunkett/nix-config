{ ... }:

{
  imports = [
    ../../../modules/common
    ../../../modules/darwin/base
    ../../../modules/darwin/server
  ];

  power.sleep = {
    computer = "never";
  };

  system.stateVersion = 6;
}

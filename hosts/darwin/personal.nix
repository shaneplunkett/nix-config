{ ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin
  ];

  users.users.vex.home = "/Users/vex";

  home-manager.users.vex = import ../../home/vex/homemac.nix;

  system.activationScripts.clamshellMode.text = ''
    /usr/bin/pmset -c disablesleep 1 sleep 0
  '';

  system.stateVersion = 6;
}

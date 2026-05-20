{ ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin
  ];

  system.activationScripts.clamshellMode.text = ''
    /usr/bin/pmset -c disablesleep 1 sleep 0
  '';

  system.stateVersion = 6;
}

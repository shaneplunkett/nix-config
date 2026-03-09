{ lib, pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin
  ];

  # Keep awake on power with lid closed (clamshell mode without external display)
  system.activationScripts.clamshellMode.text = ''
    /usr/bin/pmset -c disablesleep 1 sleep 0
  '';

  # State version for nix-darwin; leave as an integer
  system.stateVersion = 6;
}

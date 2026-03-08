{ lib, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin
  ];

  # State version for nix-darwin; leave as an integer
  system.stateVersion = 6;
}

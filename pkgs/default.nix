{ pkgs, ... }:
{
  # Define your custom packages here
  capacities = pkgs.callPackage ./capacities/capacities.nix { };
}

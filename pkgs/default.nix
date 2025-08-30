{ pkgs, ... }:
{
  # Define your custom packages here
  msty = pkgs.callPackage ./msty { };
  msty-sidecar = pkgs.callPackage ./msty-sidecar { };
}

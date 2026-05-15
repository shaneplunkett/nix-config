{ pkgs, ... }:
{
  youtui = pkgs.callPackage ./youtui/youtui.nix { };
}

{ pkgs, ... }:
{
  lazycommit = pkgs.callPackage ./lazycommit/lazycommit.nix { };

  youtui = pkgs.callPackage ./youtui/youtui.nix { };
}

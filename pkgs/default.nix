{ pkgs, ... }:
{
  claude-desktop = pkgs.callPackage ./claude-desktop/claude-desktop.nix { };

  lazycommit = pkgs.callPackage ./lazycommit/lazycommit.nix { };

  youtui = pkgs.callPackage ./youtui/youtui.nix { };

}

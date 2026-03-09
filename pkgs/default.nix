{ pkgs, ... }:
{
  claude-desktop = pkgs.callPackage ./claude-desktop/claude-desktop.nix { };

  youtui = pkgs.callPackage ./youtui/youtui.nix { };
}

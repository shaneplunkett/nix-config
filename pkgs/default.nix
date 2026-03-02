{ pkgs, ... }:
{
  capacities = pkgs.callPackage ./capacities/capacities.nix { };

  claude-desktop = pkgs.callPackage ./claude-desktop/claude-desktop.nix { };

  youtui = pkgs.callPackage ./youtui/youtui.nix { };
}

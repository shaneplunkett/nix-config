# Helpers shared between mkDarwinSystem and mkNixosSystem.
#
# The two factories were ~80% identical (overlay setup, home-manager wiring,
# sharedModules list). Both call `mkOverlays` and `mkHomeManagerModule`
# rather than duplicating the bodies inline.
{ inputs, rootPath }:
let
  inherit (inputs)
    nixvim
    catppuccin
    vex-tooling
    nix-index-database
    ;
in
{
  # Standard overlay list. Hosts append their own platform-specific overlays.
  mkOverlays =
    extras:
    [
      (final: _prev: import (rootPath + /pkgs) { pkgs = final; })
      vex-tooling.overlays.default
    ]
    ++ extras;

  # Home-manager wiring. Hosts pass their homeConfig + any extras (the NixOS
  # path adds noctalia conditionally; the Darwin path doesn't).
  mkHomeManagerModule =
    {
      homeConfig,
      extraSpecialArgs ? { },
      extraSharedModules ? [ ],
    }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs;
        }
        // extraSpecialArgs;
        users.shane = import homeConfig;
        sharedModules = [
          nixvim.homeModules.nixvim
          catppuccin.homeModules.catppuccin
          vex-tooling.homeManagerModules.default
          nix-index-database.homeModules.nix-index
        ]
        ++ extraSharedModules;
      };
    };
}

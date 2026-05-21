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
  mkOverlays =
    extras:
    [
      (
        final: _prev:
        import (rootPath + /pkgs) {
          pkgs = final;
          inherit inputs rootPath;
        }
      )
      vex-tooling.overlays.default
    ]
    ++ extras;

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

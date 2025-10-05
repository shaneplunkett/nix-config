{ inputs, rootPath }:
let
  inherit (inputs) nixpkgs home-manager nixvim stylix catppuccin;
in
{
  mkNixosSystem =
    { hostname
    , system ? "x86_64-linux"
    , hostConfig
    , extraModules ? [ ]
    ,
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        # Custom packages overlay
        {
          nixpkgs.overlays = [
            (final: prev: import (rootPath + /pkgs) { pkgs = final; })
          ];
        }

        # Host-specific configuration
        hostConfig

        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
        catppuccin.nixosModules.catppuccin

        # Home Manager configuration
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.shane = import (rootPath + /home/shane/home.nix);
            sharedModules = [
              nixvim.homeModules.nixvim
              catppuccin.homeModules.catppuccin
            ];
          };
        }
      ] ++ extraModules;
    };
}

{ inputs, rootPath }:
let
  inherit (inputs) nixpkgs nix-darwin home-manager nixvim stylix nix-homebrew homebrew-core homebrew-cask;
in
{
  mkDarwinSystem =
    { hostname
    , system ? "aarch64-darwin"
    , hostConfig
    , extraModules ? [ ]
    ,
    }:
    nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        # Custom packages overlay
        {
          nixpkgs.overlays = [
            (final: prev: import (rootPath + /pkgs) { pkgs = final; })
          ];
        }

        hostConfig

        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        stylix.darwinModules.stylix

        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            autoMigrate = true;
            user = "shane";
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };
            mutableTaps = false;
          };
        }

        ({ config, ... }: {
          homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
        })

        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.shane = import (rootPath + /home/shane/homemac.nix);
            sharedModules = [
              nixvim.homeModules.nixvim
            ];
          };
        }
      ] ++ extraModules;
    };
}

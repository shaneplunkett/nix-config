{ inputs, rootPath }:
let
  inherit (inputs)
    nixpkgs
    nix-darwin
    home-manager
    nixvim
    nix-homebrew
    homebrew-core
    homebrew-cask
    agenix
    ;
in
{
  mkDarwinSystem =
    {
      hostname,
      system ? "aarch64-darwin",
      hostConfig,
      homeConfig ? (rootPath + /home/shane/homemac.nix),
      enableHomebrew ? true,
      extraModules ? [ ],
    }:
    nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        # Custom packages overlay
        {
          nixpkgs.overlays = [
            (final: prev: import (rootPath + /pkgs) { pkgs = final; })
            (final: prev: {
              yt-dlp = prev.yt-dlp.overridePythonAttrs (old: {
                dependencies = prev.lib.concatAttrValues (builtins.removeAttrs old.optional-dependencies [ "secretstorage" ]);
              });
            })
          ];
        }

        hostConfig

        home-manager.darwinModules.home-manager
        agenix.darwinModules.default

        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.shane = import homeConfig;
            sharedModules = [
              nixvim.homeModules.nixvim
              agenix.homeManagerModules.default
            ];
          };
        }
      ]
      ++ (if enableHomebrew then [
        nix-homebrew.darwinModules.nix-homebrew

        {
          nix-homebrew = {
            enable = true;
            enableRosetta = system == "aarch64-darwin";
            autoMigrate = true;
            user = "shane";
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };
            mutableTaps = false;
          };
        }

        (
          { config, ... }:
          {
            homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
          }
        )
      ] else [ ])
      ++ extraModules;
    };
}

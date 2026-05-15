{ inputs, rootPath }:
let
  inherit (inputs)
    nix-darwin
    home-manager
    nix-homebrew
    homebrew-core
    homebrew-cask
    agenix
    ;
  common = import ./common.nix { inherit inputs rootPath; };
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
      specialArgs = { inherit inputs; };
      modules = [
        {
          nixpkgs.hostPlatform = system;
          networking.hostName = hostname;
          nixpkgs.overlays = common.mkOverlays [
            (final: prev: {
              yt-dlp = prev.yt-dlp.overridePythonAttrs (old: {
                dependencies = prev.lib.concatAttrValues (
                  builtins.removeAttrs old.optional-dependencies [ "secretstorage" ]
                );
              });
            })
          ];
        }

        hostConfig

        home-manager.darwinModules.home-manager
        agenix.darwinModules.default

        (common.mkHomeManagerModule { inherit homeConfig; })
      ]
      ++ (
        if enableHomebrew then
          [
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
          ]
        else
          [ ]
      )
      ++ extraModules;
    };
}

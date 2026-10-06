{ inputs, rootPath }:
let
  inherit (inputs)
    nix-darwin
    home-manager
    nix-homebrew
    homebrew-core
    homebrew-cask
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
      specialArgs = {
        inherit inputs;
        inherit (common) palette typography;
      };
      modules = [
        {
          nixpkgs.hostPlatform = system;
          networking.hostName = hostname;
          nixpkgs.overlays = common.mkOverlays [
            (_final: prev: {
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

        (common.mkHomeManagerModule {
          inherit homeConfig;
          extraSharedModules = [
            (rootPath + /home/shane/modules/agent-clis)
            inputs.vex-brain.homeManagerModules.vex-cli
            { programs.vex-cli.enable = true; }
          ];
        })
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

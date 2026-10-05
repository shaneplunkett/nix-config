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
        inherit (common) palette;
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

              # nixpkgs #542991 interpolates writeNu's script, so a path
              # becomes a script that runs the path. omniwm.nix passes its
              # deploy-settings.nu as a path. Fixed upstream by nixpkgs
              # b1b6be49; drop once nixos-unstable includes it.
              writers = prev.writers // {
                writeNu =
                  name: argsOrScript:
                  prev.writers.writeNu name (
                    if prev.lib.isPath argsOrScript then builtins.readFile argsOrScript else argsOrScript
                  );
              };
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

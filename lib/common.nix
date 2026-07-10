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
          isLinux = _prev.stdenv.hostPlatform.isLinux;
          isX86Linux = _prev.stdenv.hostPlatform.system == "x86_64-linux";
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
          (
            { lib, ... }:
            {
              catppuccin.autoEnable = lib.mkDefault false;
            }
          )
          vex-tooling.homeManagerModules.default
          nix-index-database.homeModules.nix-index
        ]
        ++ extraSharedModules;
      };
    };
}

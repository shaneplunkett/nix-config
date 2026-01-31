{ inputs, rootPath }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    nixvim
    agenix
    ;
in
{
  mkNixosSystem =
    {
      hostname,
      system ? "x86_64-linux",
      hostConfig,
      extraModules ? [ ],
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
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager

        # Home Manager configuration
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.shane = import (rootPath + /home/shane/home.nix);
            sharedModules = [
              nixvim.homeModules.nixvim
              agenix.homeManagerModules.default
            ];
          };
        }
      ]
      ++ extraModules;
    };
}

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
      homeConfig ? (rootPath + /home/shane/home.nix),
      extraModules ? [ ],
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        # Hostname injection + custom packages overlay
        {
          networking.hostName = hostname;
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
            users.shane = import homeConfig;
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

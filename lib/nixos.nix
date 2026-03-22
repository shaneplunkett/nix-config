{ inputs, rootPath }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    nixvim
    agenix
    catppuccin
    noctalia
    ;
in
{
  mkNixosSystem =
    {
      hostname,
      system ? "x86_64-linux",
      hostConfig,
      homeConfig ? (rootPath + /home/shane/home.nix),
      compositor ? "hyprland",
      shell ? "hyprpanel",
      extraModules ? [ ],
    }:
    nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs compositor shell; };
      modules = [
        # Hostname injection + custom packages overlay
        {
          nixpkgs.hostPlatform = system;
          networking.hostName = hostname;
          nixpkgs.overlays = [
            (final: prev: import (rootPath + /pkgs) { pkgs = final; })
          ];
        }

        # Host-specific configuration
        hostConfig
        agenix.nixosModules.default
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager

        # Home Manager configuration
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs compositor shell; };
            users.shane = import homeConfig;
            sharedModules = [
              nixvim.homeModules.nixvim
              agenix.homeManagerModules.default
              catppuccin.homeModules.catppuccin
            ] ++ nixpkgs.lib.optionals (shell == "noctalia") [
              noctalia.homeModules.default
            ];
          };
        }
      ]
      ++ extraModules;
    };
}

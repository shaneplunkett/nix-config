{ inputs, rootPath }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    nixvim
    agenix
    catppuccin
    noctalia
    claude-desktop
    vex-tooling
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
            vex-tooling.overlays.default
            claude-desktop.overlays.default
            (final: prev: {
              openldap = prev.openldap.overrideAttrs (_: { doCheck = false; });
            })
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
              vex-tooling.homeManagerModules.default
            ]
            ++ nixpkgs.lib.optionals (shell == "noctalia") [
              noctalia.homeModules.default
            ];
          };
        }
      ]
      ++ extraModules;
    };
}

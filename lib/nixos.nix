{ inputs, rootPath }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    agenix
    catppuccin
    noctalia
    claude-desktop
    ;
  common = import ./common.nix { inherit inputs rootPath; };
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
        {
          nixpkgs.hostPlatform = system;
          networking.hostName = hostname;
          nixpkgs.overlays = common.mkOverlays [
            claude-desktop.overlays.default
            (_final: prev: {
              openldap = prev.openldap.overrideAttrs (_: {
                doCheck = false;
              });
            })
          ];
        }

        hostConfig
        agenix.nixosModules.default
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager

        (common.mkHomeManagerModule {
          inherit homeConfig;
          extraSpecialArgs = { inherit compositor shell; };
          extraSharedModules = nixpkgs.lib.optionals (shell == "noctalia") [
            noctalia.homeModules.default
          ];
        })
      ]
      ++ extraModules;
    };
}

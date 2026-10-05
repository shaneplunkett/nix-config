{ inputs, rootPath }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    agenix
    catppuccin
    noctalia
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
      shell ? "noctalia",
      extraModules ? [ ],
    }:
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs shell;
        inherit (common) palette;
      };
      modules = [
        {
          nixpkgs.hostPlatform = system;
          networking.hostName = hostname;
          nixpkgs.overlays = common.mkOverlays [ ];
        }

        hostConfig
        agenix.nixosModules.default
        catppuccin.nixosModules.catppuccin
        (
          { lib, ... }:
          {
            catppuccin.autoEnable = lib.mkDefault false;
          }
        )
        home-manager.nixosModules.home-manager

        (common.mkHomeManagerModule {
          inherit homeConfig;
          extraSpecialArgs = {
            inherit shell;
          };
          extraSharedModules = [
            (rootPath + /home/shane/modules/agent-clis)
            "${inputs.vex-tooling}/modules/vex-cli.nix"
          ]
          ++ nixpkgs.lib.optionals (shell == "noctalia") [
            noctalia.homeModules.default
          ];
        })
      ]
      ++ extraModules;
    };
}

{
  description = "Shane's NixOS setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    catppuccin.url = "github:catppuccin/nix";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    sst-tap-opencode = {
      url = "github:sst/opencode";
      flake = false;

    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      catppuccin,
      nix-darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      sst-tap-opencode,
      ...
    }@inputs:
    let
      customPackagesOverlay = final: prev: import ./pkgs { pkgs = final; };
    in
    {
      darwinConfigurations."Shanes-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          { nixpkgs.overlays = [ customPackagesOverlay ]; }
          ./hosts/mac/personal.nix
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew

          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              autoMigrate = true;
              user = "shane";
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "sst/opencode" = sst-tap-opencode;
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
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.shane = import ./home/shane/homemac.nix;
              sharedModules = [
                catppuccin.homeModules.catppuccin
              ];
            };
          }
        ];
      };

      darwinConfigurations."Shanes-Work-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/mac/work.nix
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          { nixpkgs.overlays = [ customPackagesOverlay ]; }
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              autoMigrate = true;
              user = "shane";
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "sst/opencode" = sst-tap-opencode;
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
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.shane = import ./home/shane/homemac.nix;
              sharedModules = [
                catppuccin.homeModules.catppuccin
              ];
            };
          }
        ];
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/desktop/configuration.nix
          home-manager.nixosModules.home-manager
          { nixpkgs.overlays = [ customPackagesOverlay ]; }
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.shane = import ./home/shane/home.nix;
              sharedModules = [
                catppuccin.homeModules.catppuccin
              ];
            };
          }
        ];
      };
    };
}

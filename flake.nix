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

    agenix.url = "github:ryantm/agenix";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      lib = import ./lib {
        inherit inputs;
        rootPath = ./.;
      };
    in
    {
      darwinConfigurations = {
        "Shanes-MacBook-Pro" = lib.mkDarwinSystem {
          hostname = "Shanes-MacBook-Pro";
          system = "aarch64-darwin";
          hostConfig = ./hosts/darwin/personal.nix;
        };

        "Shanes-Work-MacBook-Pro" = lib.mkDarwinSystem {
          hostname = "Shanes-Work-MacBook-Pro";
          system = "aarch64-darwin";
          hostConfig = ./hosts/darwin/work.nix;
        };

        "macvm" = lib.mkDarwinSystem {
          hostname = "macvm";
          system = "x86_64-darwin";
          hostConfig = ./hosts/darwin/macvm.nix;
          homeConfig = ./home/shane/homemacserver.nix;
        };
      };

      nixosConfigurations = {
        desktop = lib.mkNixosSystem {
          hostname = "desktop";
          system = "x86_64-linux";
          hostConfig = ./hosts/desktop/configuration.nix;
        };

        hetzvps = lib.mkNixosSystem {
          hostname = "hetzvps";
          system = "aarch64-linux";
          hostConfig = ./hosts/hetzvps/configuration.nix;
          homeConfig = ./home/shane/homelinuxserver.nix;
        };
      };
    };
}

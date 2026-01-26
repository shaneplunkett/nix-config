{
  description = "Shane's NixOS setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop = {
      url = "github:shaneplunkett/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      };

      nixosConfigurations = {
        desktop = lib.mkNixosSystem {
          hostname = "desktop";
          system = "x86_64-linux";
          hostConfig = ./hosts/desktop/configuration.nix;
        };
      };
    };
}

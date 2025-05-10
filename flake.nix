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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

 outputs = { self, nixpkgs, home-manager, catppuccin, nix-darwin, ... }@inputs: {
  darwinConfigurations."Shanes-Personal-MacBook-Pro" = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
    modules = [
      ./hosts/personalmac/configuration.nix
    ];
  };

  nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./hosts/desktop/configuration.nix
      home-manager.nixosModules.home-manager
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

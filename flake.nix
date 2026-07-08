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

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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
    };
    catppuccin.url = "github:catppuccin/nix";

    # Keep Noctalia on v4 for plugin support. v5 currently drops the QML plugin
    # surface Shane's local plugins use.
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/fddc9cd584676a85d0a48225830e153178b1c000";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs/4116b41cdc89e186be7cb8b24a9b6022af95d742";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vex-tooling = {
      url = "git+ssh://git@github.com/shaneplunkett/vex-tooling.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-config-private.url = "git+ssh://git@github.com/shaneplunkett/nix-config-private.git";

    ag-ai-skills = {
      url = "git+ssh://git@github.com/autograb/ag-ai-skills.git";
      flake = false;
    };

    ai-skills = {
      url = "git+ssh://git@github.com/shaneplunkett/ai-skills.git";
      flake = false;
    };

    umu-launcher.url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";
    umu-launcher.inputs.nixpkgs.follows = "nixpkgs";

    dw-proton.url = "github:imaviso/dwproton-flake";

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Vex Noctalia plugins — provides the tl;dv recorder helper (Go binary).
    noctalia-plugins = {
      url = "git+ssh://git@github.com/shaneplunkett/noctalia-plugins.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      lib = import ./lib {
        inherit inputs;
        rootPath = ./.;
      };
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellApplication {
          name = "format-nix";
          runtimeInputs = [
            pkgs.nixfmt
            pkgs.git
          ];
          text = ''
            cd "$(git rev-parse --show-toplevel)"
            git ls-files --cached --others --exclude-standard -z '*.nix' \
              | xargs -0 -r nixfmt "$@"
          '';
        }
      );

      packages = forAllSystems (
        system:
        let
          common = import ./lib/common.nix {
            inherit inputs;
            rootPath = ./.;
          };
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = common.mkOverlays [ ];
          };
        in
        import ./pkgs {
          inherit pkgs inputs;
          rootPath = ./.;
          isLinux = nixpkgs.lib.hasSuffix "-linux" system;
          isX86Linux = system == "x86_64-linux";
        }
      );

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
          homeConfig = ./home/shane/homemac-work.nix;
        };

      };

      nixosConfigurations = {
        desktop = lib.mkNixosSystem {
          hostname = "desktop";
          system = "x86_64-linux";
          hostConfig = ./hosts/desktop/configuration.nix;
          shell = "noctalia";
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

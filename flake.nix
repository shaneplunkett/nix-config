{
  description = "Shane's NixOS setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Keep Bitwarden's security-sensitive Electron runtime independently current.
    electron-nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland deliberately keeps its own nixpkgs pin: following ours would
    # invalidate the Hyprland Cachix binary cache and force local rebuilds.
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
    # Nixvim deliberately keeps its own nixpkgs pin: upstream tests against a
    # specific revision and documents that `follows` opts out of that guarantee
    # (vimPlugins.<name> breakage). It instantiates its own nixpkgs regardless.
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OmniWM rejects any settings.toml missing a key. This flake's
    # home-manager module merges partial settings over the full defaults
    # of the OmniWM version it packages.
    omniwm = {
      url = "github:mst-mkt/omniwm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia v5 straight from upstream rather than waiting on nixpkgs. The
    # cachix branch trails main to the newest commit CI has cached. Like
    # Hyprland, it keeps its own nixpkgs pin: following ours would invalidate
    # the noctalia.cachix.org binary cache and force local builds.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";

    vex-tooling = {
      url = "git+ssh://git@github.com/shaneplunkett/vex-tooling.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-config-private.url = "git+ssh://git@github.com/shaneplunkett/nix-config-private.git";

    ai-skills = {
      url = "git+ssh://git@github.com/shaneplunkett/ai-skills.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fast-moving AI CLIs and desktop apps with cache-backed builds. Consume
    # the direct package outputs so their derivations match Numtide's cache.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # Shane's personal T3 Code fork. Treat it as source so this flake owns the
    # Nix package while updates remain a single targeted lock-file bump.
    vex-code = {
      url = "github:shaneplunkett/vex-code";
      flake = false;
    };

    # Vex Noctalia plugins (Luau, v5). Only the source tree is used: its
    # plugins/ dir is a noctalia path source, pinned here. Ship plugin changes
    # with `nix flake update noctalia-plugins`.
    noctalia-plugins = {
      url = "git+ssh://git@github.com/shaneplunkett/noctalia-plugins.git";
      flake = false;
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
        common.mkProjectPackages system pkgs
      );

      darwinConfigurations = {
        "Shanes-MacBook-Pro" = lib.mkDarwinSystem {
          hostname = "Shanes-MacBook-Pro";
          system = "aarch64-darwin";
          hostConfig = ./hosts/darwin/personal.nix;
        };
        "mini-server" = lib.mkDarwinSystem {
          hostname = "mini-server";
          system = "aarch64-darwin";
          hostConfig = ./hosts/darwin/mini/mini-server.nix;
          homeConfig = ./home/shane/homemacserver.nix;
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
          agentClis = false;
        };
      };
    };
}

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

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vex-tooling = {
      url = "git+ssh://git@github.com/shaneplunkett/vex-tooling.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Private companion repo — values that mustn't appear in the public flake
    # (work-internal URLs, work-email attributes). `nrs-iter` overrides this
    # input to the local checkout for live iteration; default URL is the
    # pinned GitHub remote so the public flake is reproducible.
    nix-config-private.url = "git+ssh://git@github.com/shaneplunkett/nix-config-private.git";

    # AutoGrab work skills — baked in via flake input so .claude/skills is
    # declaratively managed. For active iteration use `nrs-iter` which
    # `--override-input`s this to the local checkout.
    ag-ai-skills = {
      url = "git+ssh://git@github.com/autograb/ag-ai-skills.git";
      flake = false;
    };

    # Personal skills + Vex persona content (rules, agents, core.md,
    # output-style, hooks). Private repo so it's safe for credential-shaped
    # files. `nrs-iter` overrides to ~/ai-skills for live iteration.
    ai-skills = {
      url = "git+ssh://git@github.com/shaneplunkett/ai-skills.git";
      flake = false;
    };

    umu-launcher.url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";
    umu-launcher.inputs.nixpkgs.follows = "nixpkgs";

    dw-proton.url = "github:imaviso/dwproton-flake";

    claude-desktop.url = "github:aaddrick/claude-desktop-debian";

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
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
      # `nix fmt` from anywhere in the tree → nixfmt-rfc-style on every tracked
      # (or staged-but-untracked) .nix file. Excludes .gitignored paths automatically.
      # Forwards extra args: `nix fmt -- --check` for diff-only.
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
          compositor = "hyprland"; # or "niri"
          shell = "noctalia"; # or "hyprpanel"
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

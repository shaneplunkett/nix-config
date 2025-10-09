{ ... }:
{

  imports = [
    ./modules/common/btop.nix
    # ./modules/common/cava.nix  # Temporarily disabled due to unity-test build failure
    ./modules/common/direnv.nix
    ./modules/common/fish.nix
    ./modules/common/starship.nix
    ./modules/common/packages.nix
    ./modules/common/tmux.nix
    ./modules/common/git.nix
    ./modules/common/nixvim/default.nix

    ./modules/macos/ghostty.nix
  ];

  home.username = "shane";
  home.homeDirectory = "/Users/shane";

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

}

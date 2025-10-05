{ ... }:
{

  imports = [
    ./modules/common/btop.nix
    ./modules/common/cava.nix
    ./modules/common/direnv.nix
    ./modules/common/fish.nix
    ./modules/common/neovim.nix
    ./modules/common/starship.nix
    ./modules/common/packages.nix
    ./modules/common/tmux.nix
    ./modules/common/git.nix

    ./modules/macos/ghostty.nix
    ./modules/macos/packages.nix
  ];

  home.username = "shane";
  home.homeDirectory = "/Users/shane";

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

}

{ ... }:
{

  imports = [
    ./modules/common/btop.nix
    ./modules/common/terminal/direnv.nix
    ./modules/common/terminal/fish.nix
    ./modules/common/nixvim
    ./modules/common/terminal/starship.nix
    ./modules/common/terminal/tmux.nix
    ./modules/common/git.nix
    ./modules/common/age.nix
  ];

  home.username = "shane";
  home.homeDirectory = "/Users/shane";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

}

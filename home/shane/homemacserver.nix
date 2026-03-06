{ ... }:
{

  imports = [
    ./modules/common/btop.nix
    ./modules/common/direnv.nix
    ./modules/common/fish.nix
    ./modules/common/nixvim
    ./modules/common/starship.nix
    ./modules/common/tmux.nix
    ./modules/common/git.nix
    ./modules/common/age.nix
  ];

  home.username = "shane";
  home.homeDirectory = "/Users/shane";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

}

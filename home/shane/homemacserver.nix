{ ... }:
{

  imports = [
    ./modules/common/age.nix
    ./modules/common/btop.nix
    ./modules/common/git.nix
    ./modules/common/nixvim
    ./modules/common/ssh.nix
    ./modules/common/terminal
  ];

  home.username = "shane";
  home.homeDirectory = "/Users/shane";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

}

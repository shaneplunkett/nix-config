{ ... }:
{

  imports = [
    ./modules/common

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

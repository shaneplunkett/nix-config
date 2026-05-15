{ ... }:
{
  imports = [
    ./modules/common/server-profile.nix
    ./modules/common/nixvim
    # macOS servers also get the GUI-leaning terminal tooling so an
    # interactive ssh session feels like the laptop config.
    ./modules/common/terminal/bat.nix
    ./modules/common/terminal/eza.nix
    ./modules/common/terminal/fastfetch.nix
    ./modules/common/terminal/ghostty.nix
    ./modules/common/terminal/yazi.nix
  ];

  home.username = "shane";
  home.homeDirectory = "/Users/shane";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}

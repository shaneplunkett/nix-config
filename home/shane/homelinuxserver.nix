{ ... }:
{
  imports = [
    ./modules/common/server-profile.nix
  ];

  # Linux servers ship raw neovim (no nixvim — keeps the closure tiny).
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home = {
    username = "shane";
    homeDirectory = "/home/shane";
    stateVersion = "24.11";
  };
  programs.home-manager.enable = true;
}

{ ... }:
{
  imports = [
    ./modules/common/btop.nix
    ./modules/common/git.nix
    ./modules/common/ssh.nix
    ./modules/common/terminal/direnv.nix
    ./modules/common/terminal/fish.nix
    ./modules/common/terminal/sesh.nix
    ./modules/common/terminal/starship.nix
    ./modules/common/terminal/tmux.nix
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.username = "shane";
  home.homeDirectory = "/home/shane";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}

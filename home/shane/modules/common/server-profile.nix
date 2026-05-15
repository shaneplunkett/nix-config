# Minimum home-manager profile for headless servers.
#
# Both homelinuxserver.nix and homemacserver.nix import this for the
# always-shared subset. Each then adds its own extras (linux server bolts
# on raw programs.neovim; mac server adds full nixvim + the GUI-leaning
# terminal tools).
{ ... }:
{
  imports = [
    ./btop.nix
    ./git.nix
    ./ssh.nix
    ./terminal/direnv.nix
    ./terminal/fish.nix
    ./terminal/sesh.nix
    ./terminal/starship.nix
    ./terminal/tmux.nix
  ];
}

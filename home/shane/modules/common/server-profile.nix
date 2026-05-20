{ ... }:
{
  imports = [
    ./btop.nix
    ./git.nix
    ./ssh.nix
    ./terminal/direnv.nix
    ./terminal/fish.nix
    ./terminal/starship.nix
    ./terminal/tmux
  ];
}

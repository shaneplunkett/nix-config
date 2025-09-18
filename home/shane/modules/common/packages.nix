{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jq
    bat
    lsd
    lazygit
    starship
    neofetch
    obsidian
    vesktop
    go
    lazydocker
  ];
}

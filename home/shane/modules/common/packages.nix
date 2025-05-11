{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jq
    bat
    lsd
    lazygit
    starship
    neofetch
    wezterm
    vdhcoapp
    obsidian
    vesktop
  ];
}

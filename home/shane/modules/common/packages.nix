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
    obsidian
    vesktop
    google-chrome
    go
    todoist
    lazydocker
    gearlever
  ];
}

{ pkgs, ... }:
{
  home.packages = with pkgs; [
    signal-desktop
    plex-desktop
    ferdium
    vesktop
    mangohud
    protonup
    starship
    jq
    bat
    lsd
    libnotify
    bambu-studio
    pavucontrol
    blueman
    hyprshot
    hyprpaper
    obsidian
    lazygit
  ];
}

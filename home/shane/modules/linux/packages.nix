{ pkgs, ... }:
{
  home.packages = with pkgs; [
    signal-desktop
    plex-desktop
    ferdium
    vesktop
    mangohud
    protonup
    libnotify
    bambu-studio
    pavucontrol
    blueman
    hyprshot
    hyprpaper
    obsidian
  ];
}

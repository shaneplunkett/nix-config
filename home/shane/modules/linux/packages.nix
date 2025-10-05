{ pkgs, ... }:
{
  home.packages = with pkgs; [
    signal-desktop
    plex-desktop
    ferdium
    mangohud
    protonup
    libnotify
    pavucontrol
    blueman
    hyprshot
    vdhcoapp
    hyprpaper
    obsidian
    orca-slicer
    vlc
    samrewritten
    
    # GTK theme support for Wayland
    glib # for gsettings
    dconf # for dconf settings
    gtk3 # GTK3 runtime
    gtk4 # GTK4 runtime
    
  ];
  programs.chromium = {

    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}

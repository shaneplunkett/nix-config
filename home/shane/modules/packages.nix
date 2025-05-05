{pkgs, ...}: {
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
    libsForQt5.qt5.qtwayland
    papirus-icon-theme
    gtk3
    glib
    xcur2png
    rubyPackages.glib2
    libcanberra-gtk3
  ];
}

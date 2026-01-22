{
  pkgs,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    zip
    xz
    unzip
    p7zip
    signal-desktop
    plex-desktop
    ferdium
    mangohud
    protonup-ng
    ytmdesktop
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
    swaynotificationcenter
    inputs.claude-desktop.packages.${stdenv.hostPlatform.system}.claude-desktop-with-fhs
    bun
    bruno
    kubectl
    alvr
    intiface-central
  ];
  programs.chromium = {

    enable = true;
  };
}

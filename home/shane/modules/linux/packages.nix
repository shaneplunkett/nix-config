{
  pkgs,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    signal-desktop
    plex-desktop
    ferdium
    mangohud
    protonup-ng
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
    inputs.zen-browser.packages.${system}.default
    inputs.claude-desktop.packages.${system}.claude-desktop-with-fhs
    bun
    bruno
    kubectl
  ];
  programs.chromium = {

    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}

{ pkgs, inputs, ... }:
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
    swaynotificationcenter
    inputs.fsel.packages.${pkgs.system}.default
    inputs.zen-browser.packages.${system}.default
    bun
  ];
  programs.chromium = {

    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}

{
  pkgs,
  inputs,
  ...
}:
let
  electronFlags = ''
    --ozone-platform-hint=auto
    --enable-features=WaylandWindowDecorations
    --force-device-scale-factor=1.2
  '';
in
{
  # Electron app scaling flags (fractional scaling on Wayland)
  xdg.configFile."electron-flags.conf".text = electronFlags;
  xdg.configFile."electron32-flags.conf".text = electronFlags;
  xdg.configFile."electron33-flags.conf".text = electronFlags;
  xdg.configFile."electron34-flags.conf".text = electronFlags;
  xdg.configFile."chrome-flags.conf".text = electronFlags;

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
    swappy
    cliphist
    hyprpaper
    obsidian
    orca-slicer
    vlc
    samrewritten
    bun
    bruno
    kubectl
    intiface-central
    megacmd
    yt-dlp
    google-chrome
    qalculate-qt
    inputs.gws.packages.${pkgs.system}.default
  ];
}

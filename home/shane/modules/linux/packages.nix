{
  pkgs,
  ...
}:
let
  electronFlags = ''
    --ozone-platform-hint=auto
    --enable-features=WaylandWindowDecorations
    --force-device-scale-factor=1.5
  '';
  chromeFlags = ''
    --ozone-platform-hint=auto
    --enable-features=WaylandWindowDecorations
  '';
in
{
  xdg.configFile = {
    "electron-flags.conf".text = electronFlags;
    "electron32-flags.conf".text = electronFlags;
    "electron33-flags.conf".text = electronFlags;
    "electron34-flags.conf".text = electronFlags;
    "chrome-flags.conf".text = chromeFlags;
  };

  home.packages = with pkgs; [
    zip
    xz
    unzip
    p7zip
    signal-desktop
    # Temporarily disabled: upstream Snapcraft fetch is timing out during rebuilds.
    # plex-desktop
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
    slack
    qalculate-qt
  ];
}

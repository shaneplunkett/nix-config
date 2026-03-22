{
  pkgs,
  inputs,
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
  # Electron app scaling flags (fractional scaling on Wayland)
  xdg.configFile."electron-flags.conf".text = electronFlags;
  xdg.configFile."electron32-flags.conf".text = electronFlags;
  xdg.configFile."electron33-flags.conf".text = electronFlags;
  xdg.configFile."electron34-flags.conf".text = electronFlags;
  # Chrome handles fractional scaling natively via Wayland protocol — no force flag
  xdg.configFile."chrome-flags.conf".text = chromeFlags;

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
    inputs.gws.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

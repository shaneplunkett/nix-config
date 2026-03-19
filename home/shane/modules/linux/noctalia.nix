# Noctalia shell — replaces hyprpanel, rofi, swaync, hyprpaper
{ ... }:
{
  programs.noctalia-shell = {
    enable = true;
    # Colour scheme can be selected from the built-in settings GUI.
    # Community schemes (including Catppuccin) available via the scheme downloader.
  };

  # Systemd launch is deprecated; use compositor exec-once instead
  wayland.windowManager.hyprland.settings.exec-once = [
    "noctalia-shell"
  ];
}

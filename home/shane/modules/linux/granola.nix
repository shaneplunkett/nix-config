{ pkgs, ... }:
{
  home.packages = [ pkgs.granola ];

  xdg.configFile."google-chrome/NativeMessagingHosts/com.granola.app.json".source =
    "${pkgs.granola}/share/granola/com.granola.app.json";

  xdg.mimeApps.defaultApplications."x-scheme-handler/granola" = "granola.desktop";

  wayland.windowManager.hyprland.settings.windowrule = [
    "workspace 1 silent, match:class ^granola$"
    "tile 1, match:class ^granola$"
    "fullscreen_state 0 0, match:class ^granola$"
    "suppress_event maximize, match:class ^granola$"
  ];
}

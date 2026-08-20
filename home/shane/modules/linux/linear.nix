{ pkgs, ... }:
{
  home.packages = [ pkgs.linear-desktop ];

  # OAuth logins return from the browser via linear:// deep links.
  xdg.mimeApps.defaultApplications."x-scheme-handler/linear" = "linear.desktop";

  wayland.windowManager.hyprland.settings.windowrule = [
    "suppress_event maximize, match:class ^linear$"
  ];
}

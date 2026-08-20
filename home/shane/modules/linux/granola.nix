{ pkgs, ... }:
{
  home.packages = [ pkgs.granola ];

  xdg.configFile."google-chrome/NativeMessagingHosts/com.granola.app.json".source =
    "${pkgs.granola}/share/granola/com.granola.app.json";

  xdg.mimeApps.defaultApplications."x-scheme-handler/granola" = "granola.desktop";

  wayland.windowManager.hyprland.settings.window_rule = [
    {
      match.class = "^granola$";
      workspace = "10 silent"; # O — obsidian/notes workspace
      tile = true;
      fullscreen_state = "0 0";
      suppress_event = "maximize";
    }
  ];
}

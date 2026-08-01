{ pkgs, ... }:
{
  home.packages = [ pkgs.granola ];

  xdg.configFile."google-chrome/NativeMessagingHosts/com.granola.app.json".source =
    "${pkgs.granola}/share/granola/com.granola.app.json";
}

{ ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "DP-2";
          path = "~/wallpapers/kiwis.jpg";
        }
        {
          monitor = "HDMI-A-1";
          path = "~/wallpapers/kiwis.jpg";
        }
      ];
    };
  };
}

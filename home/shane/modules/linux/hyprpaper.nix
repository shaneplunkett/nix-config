{ ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "DP-2";
          path = "~/nix-config/home/shane/wallpapers/11356566-1513361830.jpg";
        }
      ];
    };
  };
}

{ ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/nix-config/home/shane/wallpapers/wallpaper.png" ];
      wallpaper = [ " , ~/nix-config/home/shane/wallpapers/wallpaper.png" ];
    };
  };
}

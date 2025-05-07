{ ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/wallpapers/trees.jpeg" ];
      wallpaper = [ " , ~/wallpapers/trees.jpeg" ];
    };
  };
}

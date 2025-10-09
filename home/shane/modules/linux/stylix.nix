{ pkgs, ... }:
{

  stylix = {

    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    image = ../../wallpapers/wallpaper.png;

    targets = {
      nixvim.enable = false;
      ghostty.enable = true;
      starship.enable = true;
      fish.enable = true;
      hyprland.enable = true;

    };
  };
}

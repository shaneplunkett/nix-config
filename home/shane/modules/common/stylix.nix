{ pkgs, ... }: {

  stylix = {

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    image = ../../wallpapers/wallpaper.png;

    targets = {
      nixvim.enable = false;
      ghostty.enable = false;
      starship.enable = false;
      fish.enable = false;
      hyprland.enable = false;

    };
  };
}

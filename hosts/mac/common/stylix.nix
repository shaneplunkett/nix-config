{ pkgs, ... }:
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
    image = ../../../home/shane/wallpapers/wallpaper.png;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.mononoki;
        name = "Mononoki Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.mononoki;
        name = "Mononoki Nerd Font";
      };
      serif = {
        package = pkgs.nerd-fonts.mononoki;
        name = "Mononoki Nerd Font";
      };
      sizes = {
        applications = 12;
        terminal = 16;
        desktop = 12;
        popups = 12;
      };
    };

    targets = {
      nixvim.enable = false;
    };
  };
}
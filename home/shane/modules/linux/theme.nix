{ pkgs, ... }:
let
  fontPackage = pkgs.nerd-fonts.mononoki;
  fontName = "Mononoki Nerd Font";
  fontSize = 12;
  cursorSize = 24;
in
{
  fonts.fontconfig.enable = true;

  home.pointerCursor = {
    size = cursorSize;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.catppuccin-cursors.mochaBlue;
    name = "catppuccin-mocha-blue-cursors";
  };

  gtk = {
    enable = true;

    font = {
      package = fontPackage;
      name = fontName;
      size = fontSize;
    };

    theme = {
      name = "catppuccin-mocha-blue-standard+rimless,black";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        tweaks = [ "rimless" "black" ];
        variant = "mocha";
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "blue";
      };
    };

    cursorTheme = {
      name = "catppuccin-mocha-blue-cursors";
      package = pkgs.catppuccin-cursors.mochaBlue;
      size = cursorSize;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk3.bookmarks = [
      "file:///home/shane/documents Documents"
      "file:///home/shane/projects Projects"
      "file:///home/shane/downloads Downloads"
      "file:///home/shane/music Music"
      "file:///home/shane/pictures Pictures"
      "file:///home/shane/templates Templates"
      "file:///home/shane/videos Videos"
      "file:///home/shane/screenshots Screenshots"
      "file:///home/shane/unraid Unraid"
    ];
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };
}
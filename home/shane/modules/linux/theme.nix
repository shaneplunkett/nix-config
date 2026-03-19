{ pkgs, ... }:
let
  fontPackage = pkgs.nerd-fonts.mononoki;
  fontName = "Mononoki Nerd Font";
  fontSize = 12;
  cursorSize = 24;
in
{
  fonts.fontconfig.enable = true;


  gtk = {
    enable = true;

    font = {
      package = fontPackage;
      name = fontName;
      size = fontSize;
    };

    # catppuccin/nix handles gtk.theme and gtk.iconTheme via catppuccin.gtk
    # catppuccin/nix handles gtk.cursorTheme via catppuccin.cursors

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

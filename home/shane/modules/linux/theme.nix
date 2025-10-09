{ ... }:

{

  catppuccin = {
    enable = false;
    fish.enable = false;
    ghostty.enable = false;
    starship.enable = false;
    gtk.icon = {
      enable = true;
      accent = "mauve";
      flavor = "mocha";
    };
    hyprland = {
      enable = false;
      accent = "pink";
      flavor = "mocha";

    };

  };
  gtk = {
    enable = true;
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

}

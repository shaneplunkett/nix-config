{ pkgs, ... }:
{
  home.pointerCursor = {
    size = 40;
    gtk.enable = true;
  };

  gtk = {
    enable = true;

    font = {
      package = pkgs.mononoki;
      name = "Mononoki Nerd Font";
      size = 10;
    };

    cursorTheme = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      size = 24;
    };

    theme = {
      name = "Catppuccin";
    };

    iconTheme = {
    };
  };
}

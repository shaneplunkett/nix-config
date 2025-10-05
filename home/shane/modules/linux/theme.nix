{ pkgs, lib, ... }:
let
  fontPackage = pkgs.mononoki;
  fontName = "Mononoki Nerd Font";
  fontSize = 12;

  cursorSize = 16;

  themePackage = pkgs.magnetic-catppuccin-gtk;
  themeName = "Catppuccin-Mocha-Standard-Mauve-Dark";

  qtPlatformTheme = "kvantum";
  qtStyleName = "kvantum";
in
{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
    mako.enable = false;
    rofi.enable = true;
    hyprland.enable = true;
    bat.enable = true;
    dunst.enable = true;
    fish.enable = true;
    starship.enable = true;
    tmux.enable = false;
    vesktop.enable = true;
    lsd.enable = true;
    nvim.enable = false;
    chromium.enable = true;
    lazygit.enable = true;
    cava.enable = true;
    cursors = {
      enable = true;
      accent = "mauve";
      flavor = "mocha";
    };
  };

  home.pointerCursor = {
    size = cursorSize;
    gtk.enable = true;
    x11 = {
      enable = true;
      defaultCursor = "left_ptr";
    };
  };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    font = {
      package = fontPackage;
      name = fontName;
      size = fontSize;
    };
    theme = {
      package = themePackage;
      name = themeName;
    };
    
    # Icon theme handled by catppuccin module below
    gtk3.bookmarks = [
      "file:///home/shane/documents Documents"
      "file:///home/shane/downloads Downloads"
      "file:///home/shane/music Music"
      "file:///home/shane/pictures Pictures"
      "file:///home/shane/templates Templates"
      "file:///home/shane/videos Videos"
      "file:///home/shane/screenshots Screenshots"
      "file:///home/shane/projects Projects"
    ];
  };

  qt = {
    enable = true;
    platformTheme.name = qtPlatformTheme;
    style.name = qtStyleName;
  };
  
  # Ensure QT applications use the GTK theme
  home.sessionVariables = {
    GTK_THEME = themeName;
    QT_QPA_PLATFORMTHEME = lib.mkForce "gtk3";
  };
}

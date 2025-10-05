{ pkgs, lib, config, ... }:
let
  fontPackage = pkgs.mononoki;
  fontName = "Mononoki Nerd Font";
  fontSize = 12;

  cursorSize = 16;
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
    kvantum.enable = true;
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
      name = "Catppuccin-Mocha-Standard-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "mocha";
        tweaks = [ "rimless" "black" ];
      };
    };
    

    
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = 1;
      bookmarks = [
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
    
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };
  
  # GTK settings for Wayland via dconf
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-size = cursorSize;
      font-name = "${fontName} ${toString fontSize}";
    };
  };
}

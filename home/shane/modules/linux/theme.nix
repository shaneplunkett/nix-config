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

  # XDG configuration files for consistent theming
  xdg.configFile = {
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme = 1
      gtk-theme-name = Catppuccin-Mocha-Standard-Mauve-Dark
      gtk-icon-theme-name = Papirus-Dark
      gtk-cursor-theme-name = catppuccin-mocha-mauve-cursors
      gtk-cursor-theme-size = ${toString cursorSize}
      gtk-font-name = ${fontName} ${toString fontSize}
      gtk-decoration-layout = menu:minimize,maximize,close
    '';
    
    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme = 1
      gtk-theme-name = Catppuccin-Mocha-Standard-Mauve-Dark
      gtk-icon-theme-name = Papirus-Dark
      gtk-cursor-theme-name = catppuccin-mocha-mauve-cursors
      gtk-cursor-theme-size = ${toString cursorSize}
      gtk-font-name = ${fontName} ${toString fontSize}
      gtk-decoration-layout = menu:minimize,maximize,close
    '';
  };

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
    
    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme = 1
      gtk-theme-name = "Catppuccin-Mocha-Standard-Mauve-Dark"
      gtk-icon-theme-name = "Papirus-Dark"
      gtk-cursor-theme-name = "catppuccin-mocha-mauve-cursors"
      gtk-cursor-theme-size = ${toString cursorSize}
      gtk-font-name = "${fontName} ${toString fontSize}"
    '';
    
    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        gtk-decoration-layout = "menu:minimize,maximize,close";
      };
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
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-decoration-layout = "menu:minimize,maximize,close";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };
  
  # GTK settings for Wayland via dconf
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Catppuccin-Mocha-Standard-Mauve-Dark";
      icon-theme = "Papirus-Dark";
      color-scheme = "prefer-dark";
      cursor-theme = "catppuccin-mocha-mauve-cursors";
      cursor-size = cursorSize;
      font-name = "${fontName} ${toString fontSize}";
    };
    "org/gnome/desktop/wm/preferences" = {
      theme = "Catppuccin-Mocha-Standard-Mauve-Dark";
    };
    # Force GTK applications to use dark theme
    "org/gtk/settings/file-chooser" = {
      show-hidden = true;
    };
  };
}
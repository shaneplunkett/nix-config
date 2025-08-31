{ pkgs, ... }:
let
  fontPackage = pkgs.mononoki;
  fontName = "Mononoki Nerd Font";
  fontSize = 12;

  cursorSize = 16;

  themePackage = pkgs.tokyonight-gtk-theme;
  themeName = "TokyoNight-Dark-BL-LB";

  qtPlatformTheme = "kvantum";
  qtStyleName = "kvantum";
in
{
  catppuccin = {
    enable = true;
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
  };

  qt = {
    enable = true;
    platformTheme.name = qtPlatformTheme;
    style.name = qtStyleName;
  };
}

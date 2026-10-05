{ pkgs, ... }:
let
  # RoundHog for interfaces, Mononoki wherever text needs a fixed width.
  uiFont = "RoundHog";
  codeFont = "Mononoki Nerd Font";
  fontSize = 12;
  cursorSize = 24;

  # One icon theme for GTK, Qt and noctalia's app icons alike.
  iconTheme = {
    name = "Reversal-purple-dark";
    package = pkgs.reversal-icon-theme.override { colorVariants = [ "purple" ]; };
  };

  # Qt's font string: family,points,-1,5,weight,then style flags.
  qtFont = family: "${family},${toString fontSize},-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
in
{
  # Most apps (Chrome, Electron, Flutter, Hyprland) take their fonts from these
  # fontconfig defaults rather than GTK.
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ uiFont ];
      serif = [ uiFont ];
      monospace = [ codeFont ];
    };
  };

  # Apps read light/dark via the xdg-desktop-portal Settings interface, which is
  # backed by this dconf key. Nothing else asserts it (noctalia only syncs it when
  # user theming/templates are enabled), so own it declaratively. The font keys
  # are what GTK4/libadwaita apps read.
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    font-name = "${uiFont} ${toString fontSize}";
    document-font-name = "${uiFont} ${toString fontSize}";
    monospace-font-name = "${codeFont} ${toString fontSize}";
  };

  home.pointerCursor = {
    enable = true;
    name = "catppuccin-mocha-mauve-cursors";
    package = pkgs.catppuccin-cursors.mochaMauve;
    size = cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;

    font = {
      package = pkgs.roundhog;
      name = uiFont;
      size = fontSize;
    };

    inherit iconTheme;

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.theme = null;
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk3.bookmarks = [
      "file:///home/shane/Documents Documents"
      "file:///home/shane/Projects Projects"
      "file:///home/shane/Downloads Downloads"
      "file:///home/shane/Music Music"
      "file:///home/shane/Pictures Pictures"
      "file:///home/shane/Templates Templates"
      "file:///home/shane/Videos Videos"
      "file:///home/shane/Screenshots Screenshots"
      "file:///home/shane/unraid Unraid"
    ];
  };

  # KDE's platform integration makes every Qt app read colours, icons, fonts
  # and the widget style from kdeglobals below, which is also the only place
  # KDE apps like Dolphin look. Kvantum draws the widgets in Catppuccin.
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "kvantum";
  };

  # Plasma normally writes kdeglobals; outside it, nothing does. Built from the
  # Catppuccin KDE scheme, with the style, icons and fonts added to it.
  xdg.configFile."kdeglobals".source =
    pkgs.runCommand "kdeglobals"
      {
        colors = "${
          pkgs.catppuccin-kde.override {
            flavour = [ "mocha" ];
            accents = [ "mauve" ];
          }
        }/share/color-schemes/CatppuccinMochaMauve.colors";
      }
      ''
        sed 's/^\[General\]$/[General]\nfont=${qtFont uiFont}\nfixed=${qtFont codeFont}/' "$colors" > $out
        printf '\n[KDE]\nwidgetStyle=kvantum\n\n[Icons]\nTheme=%s\n' ${iconTheme.name} >> $out
      '';

  catppuccin = {
    # Flavour and accent come from the shared catppuccin settings.
    kvantum.enable = true;
    # iconTheme above owns the icons, for GTK and Qt alike.
    gtk.icon.enable = false;
  };

  xdg = {
    desktopEntries = {
      plex-desktop = {
        name = "Plex";
        exec = "plex-desktop";
        icon = "plex-desktop";
        terminal = false;
        type = "Application";
        categories = [ "AudioVideo" ];
        settings.StartupWMClass = "tv.plex.Plex";
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "video/*" = "mpv.desktop";
      };
    };
  };
}

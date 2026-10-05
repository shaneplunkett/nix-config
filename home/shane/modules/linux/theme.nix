{ pkgs, ... }:
let
  # RoundHog for interfaces, Mononoki wherever text needs a fixed width.
  uiFont = "RoundHog";
  codeFont = "Mononoki Nerd Font";
  fontSize = 12;
  cursorSize = 24;
in
{
  # Most apps (Chrome, Electron, Flutter, Hyprland) take their fonts from these
  # fontconfig defaults rather than GTK.
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ uiFont ];
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

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
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

      nemo = {
        name = "Files";
        comment = "Access and organise files";
        exec = "nemo %U";
        icon = "nemo";
        terminal = false;
        type = "Application";
        categories = [
          "GNOME"
          "GTK"
          "Utility"
          "Core"
          "FileManager"
        ];
        mimeType = [ "inode/directory" ];
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "nemo.desktop";
        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "video/*" = "mpv.desktop";
      };
    };
  };
}

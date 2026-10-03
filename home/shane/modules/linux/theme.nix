{ pkgs, ... }:
let
  fontPackage = pkgs.nerd-fonts.mononoki;
  fontName = "Mononoki Nerd Font";
  fontSize = 12;
  cursorSize = 24;
in
{
  fonts.fontconfig.enable = true;

  # Apps read light/dark via the xdg-desktop-portal Settings interface, which is
  # backed by this dconf key. Nothing else asserts it (noctalia only syncs it when
  # user theming/templates are enabled), so own it declaratively.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

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
      package = fontPackage;
      name = fontName;
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
        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/x-msvideo" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";
      };
    };
  };
}

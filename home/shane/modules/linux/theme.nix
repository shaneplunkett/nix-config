{ pkgs, ... }:
let
  fontPackage = pkgs.nerd-fonts.mononoki;
  fontName = "Mononoki Nerd Font";
  fontSize = 12;
  cursorSize = 24;
in
{
  fonts.fontconfig.enable = true;

  home.pointerCursor = {
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
      "file:///home/shane/documents Documents"
      "file:///home/shane/projects Projects"
      "file:///home/shane/Downloads Downloads"
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
        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/x-msvideo" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";
      };
    };
  };
}

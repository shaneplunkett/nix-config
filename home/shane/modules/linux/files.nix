# File management: Dolphin as the file manager and Ark for archives (which also
# gives Dolphin its compress/extract menu). KIO handles trash, drives and
# thumbnails itself, so no gvfs or tumbler.
{ pkgs, ... }:
let
  archiveTypes = [
    "application/zip"
    "application/x-7z-compressed"
    "application/vnd.rar"
    "application/x-rar"
    "application/x-tar"
    "application/gzip"
    "application/x-compressed-tar"
    "application/x-bzip2-compressed-tar"
    "application/x-xz-compressed-tar"
    "application/x-zstd-compressed-tar"
    "application/zstd"
  ];
in
{
  home.packages = with pkgs.kdePackages; [
    dolphin
    ark
    kio-extras
    ffmpegthumbs
    kdegraphics-thumbnailers
  ];

  xdg = {
    # Listed as "Files" in vicinae, like the old Nemo entry.
    desktopEntries."org.kde.dolphin" = {
      name = "Files";
      comment = "Access and organise files";
      exec = "dolphin %u";
      icon = "org.kde.dolphin";
      terminal = false;
      type = "Application";
      categories = [
        "Qt"
        "KDE"
        "System"
        "FileManager"
      ];
      mimeType = [ "inode/directory" ];
    };

    # KDE builds "Open With" from the XDG application menu, which normally comes
    # from Plasma. A menu that simply includes every app is all it needs.
    configFile."menus/applications.menu".text = ''
      <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
        "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
      <Menu>
        <Name>Applications</Name>
        <DefaultAppDirs/>
        <DefaultDirectoryDirs/>
        <Include><All/></Include>
      </Menu>
    '';

    mimeApps.defaultApplications = {
      "inode/directory" = "org.kde.dolphin.desktop";
    }
    // builtins.listToAttrs (
      map (type: {
        name = type;
        value = "org.kde.ark.desktop";
      }) archiveTypes
    );
  };
}

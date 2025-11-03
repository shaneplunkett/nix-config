{
  config,
  ...
}:
{

  imports = [
    ./modules/common
    ./modules/linux
  ];

  home.username = "shane";
  home.homeDirectory = "/home/shane";
  xdg = {
    userDirs = {
      createDirectories = true;
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      videos = "${config.home.homeDirectory}/videos";
      templates = "${config.home.homeDirectory}/templates";
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/screenshots";
      };
    };
  };
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

}

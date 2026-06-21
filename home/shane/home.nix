{
  config,
  ...
}:
{

  imports = [
    ./modules/common
    ./modules/linux
  ];

  home = {
    username = "shane";
    homeDirectory = "/home/shane";
    stateVersion = "24.11";
    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
  };
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      videos = "${config.home.homeDirectory}/videos";
      templates = "${config.home.homeDirectory}/templates";
      extraConfig = {
        SCREENSHOTS = "${config.home.homeDirectory}/screenshots";
      };
    };
  };
  programs.home-manager.enable = true;
}

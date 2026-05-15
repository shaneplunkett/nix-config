_:
{

  #Homebrew
  homebrew = {
    enable = true;

    casks = [
      "ghostty"
      "postman"
      "elgato-camera-hub"
      "tailscale-app"
      "chatgpt"
      "plex"
      "hiddenbar"
      "ferdium"
      "hammerspoon"
      "docker-desktop"
      "gcloud-cli"
      "teamviewer"
      "todoist-app"
      "signal"
    ];

    brews = [
      "xcode-build-server"
    ];

    masApps = {
      "Xcode" = 497799835;
    };
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };
}

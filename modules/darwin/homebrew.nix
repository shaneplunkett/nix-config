_: {

  #Homebrew
  homebrew = {
    enable = true;

    casks = [
      "ghostty"
      "postman"
      "elgato-camera-hub"
      "tailscale-app"
      "chatgpt"
      "codex-app"
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
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

  };
}

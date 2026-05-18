_: {

  #Homebrew
  homebrew = {
    enable = true;

    casks = [
      "ghostty"
      "elgato-camera-hub"
      "tailscale-app"
      "plex"
      "ferdium"
      "hammerspoon"
      "teamviewer"
    ];

    brews = [
      "mas"
      "xcode-build-server"
    ];

    masApps = {
      "Xcode" = 497799835;
    };
    onActivation = {
      cleanup = "zap";
      autoUpdate = false;
      upgrade = false;
    };

  };
}

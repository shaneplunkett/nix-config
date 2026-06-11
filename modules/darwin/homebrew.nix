_: {

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
      "codex-app"
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

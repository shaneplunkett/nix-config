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
      "codex-app"
      "bluebubbles"
      "yt-music"
      "claude"
    ];

    brews = [
      "mas"
      "xcode-build-server"
    ];

    masApps = {
      "Xcode" = 497799835;
    };
    onActivation = {
      cleanup = "none";
      autoUpdate = false;
      upgrade = false;
    };

  };
}

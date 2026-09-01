_: {

  homebrew = {
    enable = true;

    casks = [
      "ghostty"
      "tailscale-app"
      "plex"
      "ferdium"
      "codex-app"
      "bluebubbles"
      "yt-music"
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

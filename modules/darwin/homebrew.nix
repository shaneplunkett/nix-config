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
      # nix-darwin currently emits Homebrew's removed --force-cleanup flag for "zap".
      cleanup = "none";
      extraFlags = [
        "--cleanup"
        "--zap"
      ];
      autoUpdate = false;
      upgrade = false;
    };

  };
}

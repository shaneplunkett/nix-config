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
      # Keep cleanup disabled; Homebrew now exits non-zero from bundle cleanup
      # when unmanaged formulae are present.
      cleanup = "none";
      autoUpdate = false;
      upgrade = false;
    };

  };
}

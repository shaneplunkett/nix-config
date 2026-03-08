{ ... }:
{

  #Homebrew
  homebrew = {
    enable = true;

    casks = [
      "zen"
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
      "chatgpt"
      "claude"
      "gcloud-cli"
      "teamviewer"
      "todoist-app"
    ];

    brews = [
      "gemini-cli"
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

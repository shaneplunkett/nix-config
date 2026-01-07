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
      "claude-code"
      "claude"
      "gcloud-cli"
    ];

    brews = [
      "gemini-cli"
    ];
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };
}

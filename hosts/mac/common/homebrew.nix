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
      "claude"
      "opencode"
    ];
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };
}

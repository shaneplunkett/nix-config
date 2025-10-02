{ ... }:
{

  #Homebrew
  homebrew = {
    enable = true;

    casks = [
      "zen"
      "ghostty"
      "postman"
      "duet"
      "elgato-camera-hub"
      "tailscale-app"
      "chatgpt"
      "plex"
      "hiddenbar"
      "ferdium"
      "hammerspoon"
      "docker-desktop"
      "claude"
    ];
    onActivation.cleanup = "none";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };
}

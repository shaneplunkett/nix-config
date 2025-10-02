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
    ];
    onActivation.cleanup = "zep";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };
}

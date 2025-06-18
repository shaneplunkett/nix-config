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
      "tailscale"
      "chatgpt"
      "plex"
      "hiddenbar"
    ];
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };
}

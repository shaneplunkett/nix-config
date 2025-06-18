{ ... }:
{

  #Homebrew
  homebrew = {
    enable = true;
    casks = [
      "zen"
      "ghostty"
      "figma"
      "slack"
      "postman"
      "duet"
      "elgato-camera-hub"
      "tailscale"
      "chatgpt"
      "plex"
      "hiddenbar"
    ];
    masApps = {
      "Word" = 462054704;
      "Excel" = 462058435;
    };
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };
}

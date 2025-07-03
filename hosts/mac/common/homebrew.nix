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
      "ferdium"
      "hammerspoon"
      "docker"
      "google-cloud-sdk"
    ];
    onActivation.cleanup = "uninstall";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };
}

{ ... }:
{

  #Homebrew
  homebrew = {
    enable = true;

    taps = [
      "sst/tap"
    ];

    brews = [
      "opencode"
    ];

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
      "claude"
      "cursor"
    ];
    onActivation.cleanup = "uninstall";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };
}

_: {

  homebrew = {
    enable = true;

    casks = [
      "ghostty"
      "tailscale-app"
    ];

    brews = [
      "mas"
    ];

    masApps = {
    };
    onActivation = {
      cleanup = "uninstalled";
      autoUpdate = false;
      upgrade = false;
    };

  };
}

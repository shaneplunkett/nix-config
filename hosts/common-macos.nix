{ config, pkgs, ... }:

{
  # macOS system settings
  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      dock = {
        autohide = true;
        orientation = "left";
        show-recents = false;
        static-only = true;
        tilesize = 10;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = true;
        ShowStatusBar = true;
        NewWindowTarget = "Home";
      };

      controlcenter = {
        AirDrop = true;
        Bluetooth = true;
      };

      WindowManager = {
        StandardHideDesktopIcons = true;
        EnableStandardClickToShowDesktop = false;
      };

      SoftwareUpdate = {
        AutomaticallyInstallMacOSUpdates = true;
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = false;
      };

      loginwindow = {
        GuestEnabled = false;
        LoginwindowText = "MetroKitten";
      };

      screencapture = {
        target = "clipboard";
      };

      screensaver = {
        askForPassword = true;
      };
    };
  };

  # PAM configuration for sudo with Touch ID and Apple Watch
  security.pam.services.sudo_local = {
    enable = true;
    reattach = true;
    touchIdAuth = true;
    watchIdAuth = true;
  };

  homebrew = {
    casks = [
      "zen"
      "ghostty"
      "ferdium"
      "postman"
      "duet"
      "elgato-camera-hub"
      "tailscale"
      "chatgpt"
    ];
  };
}

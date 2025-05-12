{ config, pkgs, ... }:

{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    vim
    mkalias
    alt-tab-macos
    home-manager
    raycast
    ytmdesktop
  ];
  users.users.shane.home = "/Users/shane";

  home-manager.backupFileExtension = "backup";

  programs.fish.enable = true;

  # Enable experimental Nix features
  nix.settings.experimental-features = "nix-command flakes";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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

    activationScripts.applications.text =
      let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
      pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
      '';
  };

  # PAM configuration for sudo with Touch ID and Apple Watch
  security.pam.services.sudo_local = {
    enable = true;
    reattach = true;
    touchIdAuth = true;
    watchIdAuth = true;
  };

  #Homebrew
  homebrew = {
    enable = true;
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
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };

  # State version for nix-darwin; leave as an integer
  system.stateVersion = 6;
}

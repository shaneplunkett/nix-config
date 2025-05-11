{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    mkalias
    alt-tab-macos
    home-manager
  ];

  programs.fish.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;

  system.defaults = {
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
      com.apple.swipescrolldirection = false;
    };
    loginwindow = {
      GuestEnabled = false;
      LoginwindowTest = "MetroKitten";
    };
    screencapture = {
      target = "clipboard";
    };
    keyboard = {
      remapCapsLocktoControl = true;
    };
    screensaver = {
      askForPassword = true;
    };
    power = {
      sleep = {
        display = 20;
      };
    };

  };
  security.pam.services.sudo_local = {
    reattach = true;
    touchIdAuth = true;
    watchIdAuth = true;
  };

  system.activationScripts.applications.text =
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

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}

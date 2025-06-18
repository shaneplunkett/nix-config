{ config, pkgs, ... }:

{
  imports = [
    ./common/macsettings.nix
    ./common/aerospace.nix
    ./common/fonts.nix
    ./common/user.nix
    ./common/packages.nix
    ./common/homebrew.nix
  ];

  home-manager.backupFileExtension = "backup";

  # Enable experimental Nix features
  nix.settings.experimental-features = "nix-command flakes";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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

  # State version for nix-darwin; leave as an integer
  system.stateVersion = 6;
}

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./common/macsettings.nix
    ./common/aerospace.nix
    ./common/fonts.nix
    ./common/user.nix
    ./common/packages.nix
    ./common/homebrew.nix
    ./common/fish.nix
  ];

  homebrew.casks = lib.mkAfter [
    "slack"
    "figma"
    "loom"
    "android-studio"
  ];

  homebrew.masApps = {
    "Word" = 462054704;
    "Excel" = 462058435;
  };

  environment.systemPackages = lib.mkAfter [
    pkgs.jetbrains.datagrip
  ];

  home-manager.backupFileExtension = "backup";

  # Enable experimental Nix features
  nix.settings.experimental-features = "nix-command flakes";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # State version for nix-darwin; leave as an integer
  system.stateVersion = 6;
}

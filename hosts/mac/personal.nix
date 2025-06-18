{ config, pkgs, ... }:

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

  home-manager.backupFileExtension = "backup";

  # Enable experimental Nix features
  nix.settings.experimental-features = "nix-command flakes";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # State version for nix-darwin; leave as an integer
  system.stateVersion = 6;
}

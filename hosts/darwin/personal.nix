{ lib, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin
  ];

  homebrew.masApps = {
    "Xcode" = 497799835;
  };

  home-manager.backupFileExtension = "backup";

  # State version for nix-darwin; leave as an integer
  system.stateVersion = 6;
}

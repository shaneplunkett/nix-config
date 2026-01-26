{ ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin
  ];

  home-manager.backupFileExtension = "backup";

  # State version for nix-darwin; leave as an integer
  system.stateVersion = 6;
}

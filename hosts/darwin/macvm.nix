{ ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin/user.nix
    ../../modules/darwin/maintenance.nix
  ];

  networking.hostName = "macvm";

  home-manager.backupFileExtension = "backup";

  system.stateVersion = 6;
}

{ ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin/user.nix
    ../../modules/darwin/maintenance.nix
  ];

  networking.hostName = "macvm";

  homebrew = {
    enable = true;
    brews = [ ];
    casks = [ ];
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  home-manager.backupFileExtension = "backup";

  system.stateVersion = 6;
}

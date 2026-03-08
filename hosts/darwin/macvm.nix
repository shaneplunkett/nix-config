{ pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin/user.nix
    ../../modules/darwin/maintenance.nix
    ./modules/macvm-mcp
  ];

  networking.hostName = "macvm";

  system.defaults.loginwindow.autoLoginUser = "shane";

  system.activationScripts.preventSleep.text = ''
    ${pkgs.pmset}/bin/pmset -a displaysleep 0 sleep 0 disksleep 0 2>/dev/null || \
      /usr/bin/pmset -a displaysleep 0 sleep 0 disksleep 0
  '';

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

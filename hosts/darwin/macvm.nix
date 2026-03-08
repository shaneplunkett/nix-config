{ pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin/user.nix
    ../../modules/darwin/maintenance.nix
    ./modules/macvm-mcp
  ];

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

  system.stateVersion = 6;
}

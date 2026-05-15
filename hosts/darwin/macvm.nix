{ pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin/user.nix
    ../../modules/darwin/maintenance.nix
    ./modules/macvm-mcp
  ];

  system = {
    defaults.loginwindow.autoLoginUser = "shane";
    activationScripts.preventSleep.text = ''
      ${pkgs.pmset}/bin/pmset -a displaysleep 0 sleep 0 disksleep 0 2>/dev/null || \
        /usr/bin/pmset -a displaysleep 0 sleep 0 disksleep 0
    '';
    stateVersion = 6;
  };

  homebrew = {
    enable = true;
    brews = [ ];
    casks = [ ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}

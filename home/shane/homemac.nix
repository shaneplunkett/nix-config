{ ... }:
{

  imports = [
    ./modules/common
    ./modules/darwin
  ];

  home = {
    username = "shane";
    homeDirectory = "/Users/shane";
    stateVersion = "24.11";
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  # Copy apps rather than symlink them so Spotlight and vicinae index them.
  # Laptop only: the copy needs App Management, which fails over SSH, and
  # mini-server is driven over SSH.
  targets.darwin = {
    copyApps.enable = true;
    linkApps.enable = false;
  };

  programs.home-manager.enable = true;
}

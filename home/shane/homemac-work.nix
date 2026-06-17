{ ... }:
{
  imports = [
    ./modules/common
  ];

  home = {
    username = "shane";
    homeDirectory = "/Users/shane";
    stateVersion = "24.11";
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  programs.home-manager.enable = true;
}

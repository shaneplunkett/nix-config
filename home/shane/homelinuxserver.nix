{ ... }:
{
  imports = [
    ./modules/common/server-profile.nix
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = false;
    withRuby = false;
    viAlias = true;
    vimAlias = true;
  };

  home = {
    username = "shane";
    homeDirectory = "/home/shane";
    stateVersion = "24.11";
  };
  programs.home-manager.enable = true;
}

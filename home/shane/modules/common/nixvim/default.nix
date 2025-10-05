{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    withNodeJs = true;
    viAlias = true;
    vimAlias = true;
    
    imports = [
      ./colorschemes.nix
      ./globals.nix
      ./keymaps.nix
      ./options.nix
      ./plugins
    ];
  };
}
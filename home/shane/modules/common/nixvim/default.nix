{ pkgs, ... }:
{
  imports = [
    ./colorschemes.nix
    ./globals.nix
    ./keymaps.nix
    ./options.nix
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    withNodeJs = true;
    viAlias = true;
    vimAlias = true;
  };
}
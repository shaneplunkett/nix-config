{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    withNodeJs = true;
    viAlias = true;
    vimAlias = true;

    imports = [
      ./globals.nix
      ./options.nix
      ./plugins
      ./keymaps.nix
      ./colorschemes.nix
    ];
  };
}


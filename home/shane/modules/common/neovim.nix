{ pkgs, ... }:
{

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    coc.enable = true;
    withNodeJs = true;

    extraLuaPackages = ps: [
      ps.lua
      ps.luarocks-nix
      ps.magick

    ];

    extraPackages = with pkgs; [

      # Packages
      ripgrep
      fd
      lazygit
      fzf

      #LSP
      basedpyright
      typescript-language-server

      lua-language-server
      nodePackages.jsonlint
      nixd
      nil

      #Formatters

      nixfmt-rfc-style
      shfmt
      ruff
      stylua
      luajitPackages.luacheck

    ];

  };
  home.file."./.config/nvim/" = {
    source = ./nvim;
    recursive = true;

  };
}

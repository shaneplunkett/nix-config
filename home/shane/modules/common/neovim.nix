{ pkgs, ... }:
{

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    coc.enable = false;
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
      python313Packages.python-lsp-server
      typescript-language-server
      gopls
      sqls
      terraform-ls
      vscode-langservers-extracted
      markdown-oxide
      tailwindcss-language-server
      yaml-language-server

      lua-language-server
      nodePackages.jsonlint
      nixd
      nil

      #Formatters

      nixfmt
      shfmt
      ruff
      stylua
      luajitPackages.luacheck
      prettier

    ];

  };
  home.file."./.config/nvim/" = {
    source = ./nvim;
    recursive = true;

  };
}

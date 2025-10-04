{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";
    colorschemes.catppuccin.enable = true;
    
    opts = {
      number = true;
      relativenumber = true;
      completeopt = [
        "menuone"
        "noselect"
        "noinsert"
      ];
      signcolumn = "yes:3";
      mouse = "a";
      clipboard = "unnamedplus";
      scrolloff = 5;
    };
    
    autoCmd = [
      {
        event = [ "VimEnter" ];
        callback = {
          __raw = "function() if vim.fn.argv(0) == '' then require('telescope.builtin').find_files() end end";
        };
      }
      {
        event = [ "VimEnter" ];
        command = "set relativenumber";
      }
    ];
    
    plugins = {
      web-devicons.enable = true;
      lualine.enable = true;
      tmux-navigator.enable = true;
      telescope.enable = true;
      lazygit.enable = true;
      which-key.enable = true;
      noice.enable = true;
      snacks.enable = true;
      conform-nvim.enable = true;
      lazydev.enable = true;
      
      
    };
  };
}

{ pkgs, ... }:
{

  programs.nixvim = {

    enable = true;
   globals.mapleader = " "; 
    colorschemes.catppuccin.enable = true;

    globalOpts = {
    number = true;
    relative = true;
    completeopt = [
    "menuone"
    "noselect"
    "noinsert"
    ];

    signcolumn  = "yes:3";

    mouse = "a";
    
     clipboard = {
      providers.wl-copy.enable = true;
      register = "wl-copy";
    };

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
    	lualine.enable = true;
	tmux-navigator.enable = true;
	telescope.enable = true;
	lsp.enable = true;
	lazygit.enable = true;
	which-key.enable = true;
	noice.enable = true;
	snacks.enable = true;
	conform-nvim.enable = true;
	lazydev.enable = true;
	web-devicons.enable = true;


cmp = {
  autoEnableSources = true;
  settings.sources = [
    { name = "nvim_lsp"; }
    { name = "path"; }
    { name = "buffer"; }
  ];
};

treesitter = {
enable = true;

settings = {
hightlight.enable = true;


};


};

    };





    lsp.servers.pyright = {
    	enable = true;

    };

    lsp.servers.nixd = {
    	enable = true;

    };

  };

}

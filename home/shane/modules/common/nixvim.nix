{ pkgs, ... }:
{

  programs.nixvim = {

    enable = true;
    
    colorschemes.gruvbox.enable = true;

    plugins = {
    	lualine.enable = true;
	tmux-navigatore.enable = true;
	telescope.enable = true;
	lsp.enable = true;
	lazygit.enable = true;
	which-key.enable = true;
	noice.enable = true;
	snacks.enable = true;
	confirm.enable = true;
	lazydev.enable = true;


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

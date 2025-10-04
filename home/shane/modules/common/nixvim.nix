{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    withNodeJs = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.catppuccin.enable = true;

    globals = {
    have_nerd_font = true;
    mapleader = " ";
    maplocalleader = " ";

    };

  keymaps = [
    {
      mode = "i";
      key = "jj";
      action = "<Esc>";
      options.desc = "Exit insert mode";
    }
    # more keymaps here...
  ];

    opts = {
      number = true;
      relativenumber = true;
      completeopt = [
        "menuone"
        "noselect"
        "noinsert"
      ];
      mouse = "a";
      clipboard = "unnamedplus";
      winborder = "rounded";
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      showmode = false;
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      textwidth = 0;
      wrap = true;
      signcolumn = "yes:3";
      colorcolumn = "81";
      updatetime = 250;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      list = true;
      listchars.__raw = "{ tab = '» ', trail = '·', nbsp = '␣' }";
      inccommand = "split";
      cursorline = true;
      scrolloff = 999;


    };
    plugins = {
      web-devicons.enable = true;
      gitblame.enable = true;
      flash.enable = true;
      lualine.enable = true;
      tmux-navigator.enable = true;
      telescope.enable = true;
      lazygit.enable = true;
      which-key.enable = true;
      noice.enable = true;
      snacks.enable = true;
      conform-nvim.enable = true;
      lazydev.enable = true;
      todo-comments.enable = true;
      neo-tree.enable = true;
      treesitter-context.enable = false;
      treesitter-textobjects = {
                enable = true;
                select = {
                    enable = true;
                    lookahead = true;
                };
            };
      treesitter = {
      enable = true;
      settings = {
      indent = {
      enable = true;

      };
      nixvimInjections = true;
      grammerPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;

      };

      };
            lsp-format = {
                enable = true;
            };
            lsp = {
                enable = true;
                inlayHints = true;
                servers = {


                    nixd = {
                        enable = true;
                    };

                    gopls = {
                        enable = true;
                        autostart = true;
                    };
                    pyright = {
                        enable = true;
                    };
                    lua_ls = {
                        enable = true;
                        settings.telemetry.enable = false;
                    };


                };


            };
    };
  };
}

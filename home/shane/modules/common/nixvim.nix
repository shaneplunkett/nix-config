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
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>LazyGit<CR>";
        options = {
          desc = "LazyGit (root dir)";
        };
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
      opencode = {
        enable = true;
        settings = {
          input.enabled = true;

        };

      };
      snacks = {
        enable = true;
        settings = {
          bigfile.enable = true;
          animate.enable = false;
          indent.enable = true;
          input.enable = true;
          scope.enable = true;
          scroll.enable = true;
          statuscolumn.enable = true;
          words.enable = true;

          notifier = {
            enable = true;
            timeout = 3000;
            top_down = false;
            border = "rounded";
          };
          styles = {
            notification = {
              wo = {
                wrap = true;
              };

            };

          };
        };
      };
      blink-cmp = {
        enable = true;
        setupLspCapabilities = true;

      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            "_" = [ "time_whitespace" ];
            css = [ "biome" ];
            html = [ "biome" ];
            svg = [ "biome" ];
            fish = [ "fish_indent" ];
            javascript = [ "prettier" ];
            javascriptreact = [ "prettier" ];
            json = [ "prettier" ];
            jsonc = [ "prettier" ];
            lua = [ "stylua" ];
            nix = [ "nixfmt" ];
            mdx = [ "prettier" ];
            markdown = [ "prettier" ];
            python = [ "ruff" ];
            sh = [ "shfmt" ];
            svelte = [ "prettier" ];
            typescript = [ "prettier" ];
            rust = [ "rustfmt" ];
            go = [ "gofmt" ];
            astro = [ "prettier" ];
            terraform = [ "terraform_fmt" ];
            tf = [ "terraform_fmt" ];
            sql = [ "sqlfluff" ];
            pgsql = [ "sqlfluff" ];
          };
          format_on_save = ''
            function(bufnr)
            local ignore_filetypes = { "helm" }
            if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
            return
            end

            -- Disable with a global or buffer-local variable
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
            end

            -- Disable autoformat for files in a certain path
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname:match("/node_modules/") then
            return
            end
            return { timeout_ms = 1000, lsp_fallback = true }
            end
          '';
        };

      };
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
      lsp = {
        enable = true;
        inlayHints = true;
        servers = {

          nixd = {
            enable = true;
            settings = {
              formatting.command = [ "nixpkgs-fmt" ];
              nixpkgs.expr = "import <nixpkgs> {}";
            };
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

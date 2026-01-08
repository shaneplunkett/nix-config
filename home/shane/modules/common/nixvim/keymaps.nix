{ self, ... }:
{
  keymaps = [
    {
      mode = "i";
      key = "jj";
      action = "<Esc>";
      options.desc = "Exit insert mode";
    }
    {
      mode = "n";
      key = "\\";
      action = ":Neotree toggle right<CR>";
      options.desc = "NeoTree toggle";
    }
    # Top Pickers & Explorer
    {
      mode = "n";
      key = "<leader><space>";
      action.__raw = ''
        function()
          Snacks.picker.smart()
        end
      '';
      options.desc = "Smart Find Files";
    }
    {
      mode = "n";
      key = "<leader>,";
      action.__raw = ''
        function()
          Snacks.picker.buffers()
        end
      '';
      options.desc = "Buffers";
    }
   
    # LSP
    {
      mode = "n";
      key = "gd";
      action.__raw = ''
        function()
          Snacks.picker.lsp_definitions()
        end
      '';
      options.desc = "Goto Definition";
    }
    {
      mode = "n";
      key = "gD";
      action.__raw = ''
        function()
          Snacks.picker.lsp_declarations()
        end
      '';
      options.desc = "Goto Declaration";
    }
    {
      mode = "n";
      key = "gI";
      action.__raw = ''
        function()
          Snacks.picker.lsp_implementations()
        end
      '';
      options.desc = "Goto Implementation";
    }
    {
      mode = "n";
      key = "gy";
      action.__raw = ''
        function()
          Snacks.picker.lsp_type_definitions()
        end
      '';
      options.desc = "Goto T[y]pe Definition";
    }
    {
      mode = "n";
      key = "<leader>ss";
      action.__raw = ''
        function()
          Snacks.picker.lsp_symbols()
        end
      '';
      options.desc = "LSP Symbols";
    }
    {
      mode = "n";
      key = "<leader>sS";
      action.__raw = ''
        function()
          Snacks.picker.lsp_workspace_symbols()
        end
      '';
      options.desc = "LSP Workspace Symbols";
    }

    # Other
    {
      mode = "n";
      key = "<leader>z";
      action.__raw = ''
        function()
          Snacks.zen()
        end
      '';
      options.desc = "Toggle Zen Mode";
    }
    {
      mode = "n";
      key = "<leader>Z";
      action.__raw = ''
        function()
          Snacks.zen.zoom()
        end
      '';
      options.desc = "Toggle Zoom";
    }
    {
      mode = "n";
      key = "<leader>.";
      action.__raw = ''
        function()
          Snacks.scratch()
        end
      '';
      options.desc = "Toggle Scratch Buffer";
    }
    {
      mode = "n";
      key = "<leader>S";
      action.__raw = ''
        function()
          Snacks.scratch.select()
        end
      '';
      options.desc = "Select Scratch Buffer";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action.__raw = ''
        function()
          Snacks.bufdelete()
        end
      '';
      options.desc = "Delete Buffer";
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>gB";
      action.__raw = ''
        function()
          Snacks.gitbrowse()
        end
      '';
      options.desc = "Git Browse";
    }
    {
      mode = "n";
      key = "<leader>gg";
      action.__raw = ''
        function()
          Snacks.lazygit()
        end
      '';
      options.desc = "Lazygit";
    }
    {
      mode = "n";
      key = "<leader>un";
      action.__raw = ''
        function()
          Snacks.notifier.hide()
        end
      '';
      options.desc = "Dismiss All Notifications";
    }
    {
      mode = "n";
      key = "<c-/>";
      action.__raw = ''
        function()
          Snacks.terminal()
        end
      '';
      options.desc = "Toggle Terminal";
    }
    {
      mode = "n";
      key = "<c-_>";
      action.__raw = ''
        function()
          Snacks.terminal()
        end
      '';
      options.desc = "which_key_ignore";
    }
    {
      mode = [
        "n"
        "t"
      ];
      key = "]]";
      action.__raw = ''
        function()
          Snacks.words.jump(vim.v.count1)
        end
      '';
      options.desc = "Next Reference";
    }
    {
      mode = [
        "n"
        "t"
      ];
      key = "[[";
      action.__raw = ''
        function()
          Snacks.words.jump(-vim.v.count1)
        end
      '';
      options.desc = "Prev Reference";
    }
    {
      mode = "n";
      key = "<leader>N";
      action.__raw = ''
        function()
          Snacks.win {
            file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
            width = 0.6,
            height = 0.6,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = 'yes',
              statuscolumn = ' ',
              conceallevel = 3,
            },
          }
        end
      '';
      options.desc = "Neovim News";
    }
    {
      mode = "n";
      key = "<leader>ot";
      action.__raw = ''
        function()
          require('opencode').toggle()
        end
      '';
      options.desc = "Toggle embedded";
    }
    {
      mode = "n";
      key = "<leader>oa";
      action.__raw = ''
        function()
          require('opencode').ask '@cursor: '
        end
      '';
      options.desc = "Ask about this";
    }
    {
      mode = "v";
      key = "<leader>oa";
      action.__raw = ''
        function()
          require('opencode').ask '@selection: '
        end
      '';
      options.desc = "Ask about selection";
    }
    {
      mode = "n";
      key = "<leader>o+";
      action.__raw = ''
        function()
          require('opencode').prompt('@buffer', { append = true })
        end
      '';
      options.desc = "Add buffer to prompt";
    }
    {
      mode = "v";
      key = "<leader>o+";
      action.__raw = ''
        function()
          require('opencode').prompt('@selection', { append = true })
        end
      '';
      options.desc = "Add selection to prompt";
    }
    {
      mode = "n";
      key = "<leader>oe";
      action.__raw = ''
        function()
          require('opencode').prompt 'Explain @cursor and its context'
        end
      '';
      options.desc = "Explain this code";
    }
    {
      mode = "n";
      key = "<leader>on";
      action.__raw = ''
        function()
          require('opencode').command 'session_new'
        end
      '';
      options.desc = "New session";
    }
    {
      mode = "n";
      key = "<S-C-u>";
      action.__raw = ''
        function()
          require('opencode').command 'messages_half_page_up'
        end
      '';
      options.desc = "Messages half page up";
    }
    {
      mode = "n";
      key = "<S-C-d>";
      action.__raw = ''
        function()
          require('opencode').command 'messages_half_page_down'
        end
      '';
      options.desc = "Messages half page down";
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>os";
      action.__raw = ''
        function()
          require('opencode').select()
        end
      '';
      options.desc = "Select prompt";
    }
    {
      mode = "n";
      key = "]t";
      action.__raw = ''
        function()
          require("todo-comments").jump_next()
        end
      '';
      options.desc = "Next Todo Comment";
    }
    {
      mode = "n";
      key = "[t";
      action.__raw = ''
        function()
          require("todo-comments").jump_prev()
        end
      '';
      options.desc = "Previous Todo Comment";
    }
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble todo toggle<cr>";
      options.desc = "Todo (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xt";
      action = "<cmd>Trouble todo toggle<cr>";
      options.desc = "Todo (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xT";
      action = "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>";
      options.desc = "Todo/Fix/Fixme (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>st";
      action = "<cmd>TodoTelescope<cr>";
      options.desc = "Todo";
    }
    {
      mode = "n";
      key = "<leader>sT";
      action = "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>";
      options.desc = "Todo/Fix/Fixme";
    }
    # more keymaps here...
  ];

}

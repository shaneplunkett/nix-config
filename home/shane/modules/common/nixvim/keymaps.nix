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
      action = ":Neotree reveal right<CR>";
      options.desc = "NeoTree reveal";
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
    {
      mode = "n";
      key = "<leader>/";
      action.__raw = ''
        function()
          Snacks.picker.grep()
        end
      '';
      options.desc = "Grep";
    }
    {
      mode = "n";
      key = "<leader>:";
      action.__raw = ''
        function()
          Snacks.picker.command_history()
        end
      '';
      options.desc = "Command History";
    }
    {
      mode = "n";
      key = "<leader>n";
      action.__raw = ''
        function()
          Snacks.picker.notifications()
        end
      '';
      options.desc = "Notification History";
    }
    {
      mode = "n";
      key = "<leader>e";
      action.__raw = ''
        function()
          Snacks.explorer()
        end
      '';
      options.desc = "File Explorer";
    }

    # find
    {
      mode = "n";
      key = "<leader>fb";
      action.__raw = ''
        function()
          Snacks.picker.buffers()
        end
      '';
      options.desc = "Buffers";
    }
    {
      mode = "n";
      key = "<leader>fc";
      action.__raw = ''
        function()
          Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
        end
      '';
      options.desc = "Find Config File";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action.__raw = ''
        function()
          Snacks.picker.files()
        end
      '';
      options.desc = "Find Files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action.__raw = ''
        function()
          Snacks.picker.git_files()
        end
      '';
      options.desc = "Find Git Files";
    }
    {
      mode = "n";
      key = "<leader>fp";
      action.__raw = ''
        function()
          Snacks.picker.projects()
        end
      '';
      options.desc = "Projects";
    }
    {
      mode = "n";
      key = "<leader>fr";
      action.__raw = ''
        function()
          Snacks.picker.recent()
        end
      '';
      options.desc = "Recent";
    }

    # git
    {
      mode = "n";
      key = "<leader>gb";
      action.__raw = ''
        function()
          Snacks.picker.git_branches()
        end
      '';
      options.desc = "Git Branches";
    }
    {
      mode = "n";
      key = "<leader>gl";
      action.__raw = ''
        function()
          Snacks.picker.git_log()
        end
      '';
      options.desc = "Git Log";
    }
    {
      mode = "n";
      key = "<leader>gL";
      action.__raw = ''
        function()
          Snacks.picker.git_log_line()
        end
      '';
      options.desc = "Git Log Line";
    }
    {
      mode = "n";
      key = "<leader>gs";
      action.__raw = ''
        function()
          Snacks.picker.git_status()
        end
      '';
      options.desc = "Git Status";
    }
    {
      mode = "n";
      key = "<leader>gS";
      action.__raw = ''
        function()
          Snacks.picker.git_stash()
        end
      '';
      options.desc = "Git Stash";
    }
    {
      mode = "n";
      key = "<leader>gd";
      action.__raw = ''
        function()
          Snacks.picker.git_diff()
        end
      '';
      options.desc = "Git Diff (Hunks)";
    }
    {
      mode = "n";
      key = "<leader>gf";
      action.__raw = ''
        function()
          Snacks.picker.git_log_file()
        end
      '';
      options.desc = "Git Log File";
    }

    # Grep
    {
      mode = "n";
      key = "<leader>sb";
      action.__raw = ''
        function()
          Snacks.picker.lines()
        end
      '';
      options.desc = "Buffer Lines";
    }
    {
      mode = "n";
      key = "<leader>sB";
      action.__raw = ''
        function()
          Snacks.picker.grep_buffers()
        end
      '';
      options.desc = "Grep Open Buffers";
    }
    {
      mode = "n";
      key = "<leader>sg";
      action.__raw = ''
        function()
          Snacks.picker.grep()
        end
      '';
      options.desc = "Grep";
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>sw";
      action.__raw = ''
        function()
          Snacks.picker.grep_word()
        end
      '';
      options.desc = "Visual selection or word";
    }

    # search
    {
      mode = "n";
      key = "<leader>s\"";
      action.__raw = ''
        function()
          Snacks.picker.registers()
        end
      '';
      options.desc = "Registers";
    }
    {
      mode = "n";
      key = "<leader>s/";
      action.__raw = ''
        function()
          Snacks.picker.search_history()
        end
      '';
      options.desc = "Search History";
    }
    {
      mode = "n";
      key = "<leader>sa";
      action.__raw = ''
        function()
          Snacks.picker.autocmds()
        end
      '';
      options.desc = "Autocmds";
    }
    {
      mode = "n";
      key = "<leader>sc";
      action.__raw = ''
        function()
          Snacks.picker.command_history()
        end
      '';
      options.desc = "Command History";
    }
    {
      mode = "n";
      key = "<leader>sC";
      action.__raw = ''
        function()
          Snacks.picker.commands()
        end
      '';
      options.desc = "Commands";
    }
    {
      mode = "n";
      key = "<leader>sd";
      action.__raw = ''
        function()
          Snacks.picker.diagnostics()
        end
      '';
      options.desc = "Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>sD";
      action.__raw = ''
        function()
          Snacks.picker.diagnostics_buffer()
        end
      '';
      options.desc = "Buffer Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>sh";
      action.__raw = ''
        function()
          Snacks.picker.help()
        end
      '';
      options.desc = "Help Pages";
    }
    {
      mode = "n";
      key = "<leader>sH";
      action.__raw = ''
        function()
          Snacks.picker.highlights()
        end
      '';
      options.desc = "Highlights";
    }
    {
      mode = "n";
      key = "<leader>si";
      action.__raw = ''
        function()
          Snacks.picker.icons()
        end
      '';
      options.desc = "Icons";
    }
    {
      mode = "n";
      key = "<leader>sj";
      action.__raw = ''
        function()
          Snacks.picker.jumps()
        end
      '';
      options.desc = "Jumps";
    }
    {
      mode = "n";
      key = "<leader>sk";
      action.__raw = ''
        function()
          Snacks.picker.keymaps()
        end
      '';
      options.desc = "Keymaps";
    }
    {
      mode = "n";
      key = "<leader>sl";
      action.__raw = ''
        function()
          Snacks.picker.loclist()
        end
      '';
      options.desc = "Location List";
    }
    {
      mode = "n";
      key = "<leader>sm";
      action.__raw = ''
        function()
          Snacks.picker.marks()
        end
      '';
      options.desc = "Marks";
    }
    {
      mode = "n";
      key = "<leader>sM";
      action.__raw = ''
        function()
          Snacks.picker.man()
        end
      '';
      options.desc = "Man Pages";
    }
    {
      mode = "n";
      key = "<leader>sp";
      action.__raw = ''
        function()
          Snacks.picker.lazy()
        end
      '';
      options.desc = "Search for Plugin Spec";
    }
    {
      mode = "n";
      key = "<leader>sq";
      action.__raw = ''
        function()
          Snacks.picker.qflist()
        end
      '';
      options.desc = "Quickfix List";
    }
    {
      mode = "n";
      key = "<leader>sR";
      action.__raw = ''
        function()
          Snacks.picker.resume()
        end
      '';
      options.desc = "Resume";
    }
    {
      mode = "n";
      key = "<leader>su";
      action.__raw = ''
        function()
          Snacks.picker.undo()
        end
      '';
      options.desc = "Undo History";
    }
    {
      mode = "n";
      key = "<leader>uC";
      action.__raw = ''
        function()
          Snacks.picker.colorschemes()
        end
      '';
      options.desc = "Colorschemes";
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

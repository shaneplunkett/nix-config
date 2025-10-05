{ pkgs, ... }:
{
  plugins = {
    neo-tree = {
      enable = true;
      
      # Sources configuration
      sources = [ "filesystem" "buffers" "git_status" ];
      
      # Filesystem configuration
      filesystem = {
        filteredItems = {
          visible = true;
          showHiddenCount = true;
          hideDotfiles = false;
          hideGitignored = false;
          hideByName = [
            ".git"
            ".DS_Store"
            "thumbs.db"
          ];
          neverShow = [ ];
        };
        bindToCwd = false;
        followCurrentFile.enabled = true;
        useLibuvFileWatcher = true;
      };
      
      # Window configuration
      window.mappings = {
        "\\" = "close_window";
        "l" = "open";
        "h" = "close_node";
        "<space>" = "none";
      };
      

      
      # Component configs
      defaultComponentConfigs = {
        indent = {
          withExpanders = true;
          expanderCollapsed = "";
          expanderExpanded = "";
          expanderHighlight = "NeoTreeExpander";
        };
        gitStatus = {
          symbols = {
            unstaged = "󰄱";
            staged = "󰱒";
          };
        };
      };
    };
  };
  
  # Add auto-close behavior and custom mappings via extraConfigLua
  extraConfigLua = ''
    -- Auto-close neo-tree when a file is opened
    vim.api.nvim_create_autocmd("User", {
      pattern = "Neo-treeBufEnter",
      callback = function()
        local neo_tree = require('neo-tree')
        vim.api.nvim_create_autocmd("BufEnter", {
          callback = function()
            if vim.bo.filetype ~= 'neo-tree' then
              neo_tree.close_all()
            end
          end,
          once = true,
        })
      end,
    })
    
    -- Additional neo-tree configuration for auto-close on file open
    require('neo-tree').setup({
      event_handlers = {
        {
          event = "file_opened",
          handler = function(file_path)
            require('neo-tree').close_all()
          end
        },
      }
    })
  '';
}

{ self, ... }:
{
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "mocha";
      
      # Color overrides matching your old config
      color_overrides = {
        mocha = {
          mantle = "#1e1e2e";
        };
      };
      
      # Background and visual settings
      transparent_background = false;
      
      # Dim inactive windows
      dim_inactive = {
        enabled = true;
      };
      
      # Plugin integrations from your old config
      default_integrations = true;
      integrations = {
        # Core integrations
        cmp = true;
        gitsigns = true;
        treesitter = true;
        which_key = true;
        
        # UI integrations
        alpha = true;
        dashboard = true;
        flash = true;
        notify = true;
        
        # File explorer
        neotree = true;
        
        # LSP and diagnostics
        lsp_trouble = true;
        mason = true;
        
        # Telescope
        telescope = {
          enabled = true;
        };
        
        # Development tools
        copilot_vim = true;
        dap = true;
        dap_ui = true;
        fidget = true;
        harpoon = true;
        
        # Indent guides
        indent_blankline = {
          enabled = true;
          scope_color = "lavender";
          colored_indent_levels = false;
        };
        
        # Mini.nvim
        mini = {
          enabled = true;
          indentscope_color = "base";
        };
        
        # Noice UI enhancements
        noice = true;
        notifier = true;
        snacks = true;
        
        # LSP styling matching your old config
        native_lsp = {
          enabled = true;
          virtual_text = {
            errors = [ "italic" ];
            hints = [ "italic" ];
            warnings = [ "italic" ];
            information = [ "italic" ];
            ok = [ "italic" ];
          };
          underlines = {
            errors = [ "underline" ];
            hints = [ "underline" ];
            warnings = [ "underline" ];
            information = [ "underline" ];
            ok = [ "underline" ];
          };
          inlay_hints = {
            background = true;
          };
        };
      };
      
      # Custom highlights (empty in your old config, but ready for future use)
      custom_highlights = { };
    };
  };
}

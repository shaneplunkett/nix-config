{ self, ... }:
{
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "mocha";

      color_overrides = {
        mocha = {
          mantle = "#1e1e2e";
        };
      };

      transparent_background = false;

      dim_inactive = {
        enabled = false;
      };

      default_integrations = true;
      integrations = {
        cmp = true;
        gitsigns = true;
        treesitter = true;
        which_key = true;

        alpha = true;
        dashboard = true;
        flash = true;
        notify = true;

        neotree = true;

        lsp_trouble = true;
        mason = true;

        telescope = {
          enabled = true;
        };

        copilot_vim = true;
        dap = true;
        dap_ui = true;
        fidget = true;
        harpoon = true;

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

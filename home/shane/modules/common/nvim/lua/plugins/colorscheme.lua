return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      flavour = 'mocha',
      color_overrides = {
        mocha = {
          mantle = '#1e1e2e',
        },
      },
      custom_highlights = {},
      transparent_background = false,
      dim_inactive = {
        enabled = true,
      },
      default_integrations = true,
      integrations = {
        alpha = true,
        blink_cmp = true,
        cmp = true,
        copilot_vim = true,
        dashboard = true,
        dap = true,
        dap_ui = true,
        fidget = true,
        flash = true,
        gitsigns = true,
        harpoon = true,
        indent_blankline = {
          enabled = true,
          scope_color = 'lavender',
          colored_indent_levels = false,
        },
        lsp_trouble = true,
        mason = true,
        mini = { enabled = true, indentscope_color = 'base' },
        neotree = true,
        notify = true,
        notifier = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
            ok = { 'italic' },
          },
          underlines = {
            errors = { 'underline' },
            hints = { 'underline' },
            warnings = { 'underline' },
            information = { 'underline' },
            ok = { 'underline' },
          },
          inlay_hints = {
            background = true,
          },
        },
        noice = true,
        snacks = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
      },
    }
    vim.cmd.colorscheme 'catppuccin'
  end,
}

return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        css = { 'prettierd', 'prettier', stop_after_first = true },
        graphql = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        lua = { 'stylua' },
        markdown = { 'prettierd', 'prettier', stop_after_first = true },
        sql = { 'sql-formatter' },
        svelte = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', 'sql-formatter', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettier' },
        xml = { 'xmlformatter' },
        python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
        go = { 'goimports-reviser', 'gofumpt', 'golines' },
        php = { 'pint', 'php_cs_fixer', stop_after_first = true },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et

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
        css = { 'biome' },
        html = { 'biome' },
        svg = { 'biome' },
        elixir = { 'mix format' },
        fish = { 'fish_indent' },
        javascript = { 'prettier' },
        json = { 'prettier' },
        jsonc = { 'prettier' },
        lua = { 'stylua' },
        nix = { 'nixfmt' },
        mdx = { 'prettier' },
        markdown = { 'prettier' },
        python = { 'black' },
        sh = { 'shfmt' },
        svelte = { 'prettier' },
        typescript = { 'prettier' },
        rust = { 'rustfmt' },
        go = { 'go fmt' },
        astro = { 'prettier' },
        ruby = { 'rufo' },
        terraform = { 'terraform fmt' },
        tf = { 'terraform_fmt' },
        sql = { 'sqlfluff' },
        pgsql = { 'sqlfluff' },
      },
      formatters = {
        sqlfluff = {
          command = 'sqlfluff',
          args = { 'format', '--dialect=postgres', '-' },
          stdin = true,
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
      },
    },
  },
}

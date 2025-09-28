return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      default_format_opts = {
        lsp_format = 'fallback',
      },
      format_on_save = {
        lsp_format = 'fallback',
        timeout_ms = 500,
      },
      formatters_by_ft = {
        css = { 'biome' },
        html = { 'biome' },
        svg = { 'biome' },
        fish = { 'fish_indent' },
        javascript = { 'prettier' },
        javascriptreact = { 'prettier' },
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
        go = { 'gofmt' },
        astro = { 'prettier' },
        ruby = { 'rufo' },
        terraform = { 'terraform_fmt' },
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

return {
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/nvim-cmp' },
  { 'L3MON4D3/LuaSnip' },
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    config = function()
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      require('lspconfig').lua_ls.setup {}
      require('lspconfig').nil_ls.setup {}
      require('lspconfig').nixd.setup {
        cmd = { 'nixd' },
        filetypes = { 'nix' },
        settings = {
          nixd = {
            nixpkgs = {
              expr = 'import <nixpkgs> { }',
            },
            options = {
              nixos = {
                expr = '(builtins.getFlake "/home/wout/.nix").nixosConfigurations.framework.options',
              },
            },
          },
        },
      }
      require('lspconfig').basedpyright.setup {
        filetypes = { 'python' },
      }
      require('lspconfig').ts_ls.setup {}
      require('lspconfig').terraformls.setup {}
      require('lspconfig').rust_analyzer.setup {}
      require('lspconfig').gopls.setup {
        filetypes = { 'go', 'gomod' },
      }
      require('lspconfig').astro.setup {}
      require('lspconfig').ruby_lsp.setup {}
      require('lspconfig').sqls.setup {}
      require('lspconfig').html.setup {
        filetypes = { 'html', 'handlebars', 'html.handlebars', 'html.hbs' },
      }
    end,
  },
}

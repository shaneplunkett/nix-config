vim.lsp.enable 'lua_ls'
vim.lsp.enable 'nixd'
vim.lsp.enable 'ts_ls'
vim.lsp.enable 'gopls'
vim.lsp.enable 'basedpyright'

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method 'textDocument/completion' then
      vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.diagnostic.config {
  virtual_lines = {
    current_line = true,
  },
}

return {
  cmd = { 'lua-language-server' },

  filetypes = { 'lua' },

  root_markers = { { '.luarc.json', '.luarc.jsonc', '.luacheckrc' }, '.git' },

  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
}

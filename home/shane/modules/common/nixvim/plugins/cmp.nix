{ pkgs, ... }:
{
  plugins = {
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        mapping = {
          # Navigate completion menu
          "<C-k>" = "cmp.mapping.select_prev_item()";
          "<C-j>" = "cmp.mapping.select_next_item()";
          
          # Trigger completion
          "<C-Space>" = "cmp.mapping.complete()";
          
          # Close completion
          "<C-e>" = "cmp.mapping.abort()";
          
          # Accept completion
          "<CR>" = "cmp.mapping.confirm({ select = false })";
          "<Tab>" = "cmp.mapping.confirm({ select = true })";
          
          # Navigate snippet placeholders
          "<C-f>" = ''
            cmp.mapping(function(fallback)
              local luasnip = require('luasnip')
              if luasnip.jumpable(1) then
                luasnip.jump(1)
              else
                fallback()
              end
            end, { 'i', 's' })
          '';
          "<C-b>" = ''
            cmp.mapping(function(fallback)
              local luasnip = require('luasnip')
              if luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' })
          '';
          
          # Scroll documentation
          "<C-u>" = "cmp.mapping.scroll_docs(-4)";
          "<C-d>" = "cmp.mapping.scroll_docs(4)";
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "nvim_lsp_signature_help"; }
          { name = "luasnip"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        window = {
          completion = "cmp.config.window.bordered()";
          documentation = "cmp.config.window.bordered()";
        };
        formatting = {
          format = ''
            function(entry, vim_item)
              local kind_icons = {
                Text = '󰉿',
                Method = '󰆧',
                Function = '󰊕',
                Constructor = '',
                Field = '󰜢',
                Variable = '󰀫',
                Class = '󰠱',
                Interface = '',
                Module = '',
                Property = '󰜢',
                Unit = '󰑭',
                Value = '󰎠',
                Enum = '',
                Keyword = '󰌋',
                Snippet = '',
                Color = '󰏘',
                File = '󰈙',
                Reference = '󰈇',
                Folder = '󰉋',
                EnumMember = '',
                Constant = '󰏿',
                Struct = '󰙅',
                Event = '',
                Operator = '󰆕',
                TypeParameter = '',
              }
              
              vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
              vim_item.menu = ({
                nvim_lsp = '[LSP]',
                nvim_lsp_signature_help = '[Signature]',
                luasnip = '[Snippet]',
                buffer = '[Buffer]',
                path = '[Path]',
              })[entry.source.name]
              
              return vim_item
            end
          '';
        };
        experimental = {
          ghost_text = true;
        };
      };
    };
    
    cmp-nvim-lsp-signature-help.enable = true;
    cmp-cmdline = {
      enable = true;
      settings = {
        search = {
          mapping = "cmp.mapping.preset.cmdline()";
          sources = [
            { name = "buffer"; }
          ];
        };
        cmdline = {
          mapping = "cmp.mapping.preset.cmdline()";
          sources = [
            { name = "path"; }
            { name = "cmdline"; }
          ];
        };
      };
    };
  };
}

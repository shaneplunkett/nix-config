{ pkgs, ... }:
{

  plugins = {
    lsp-format = {
      enable = true;
    };

    lsp-status = {
      enable = true;
    };

    lsp = {
      enable = true;
      inlayHints = true;
      servers = {

        nixd = {
          enable = true;
          settings = {
            formatting.command = [ "nixpkgs-fmt" ];
            nixpkgs.expr = "import <nixpkgs> {}";
          };
        };

        gopls = {
          enable = true;
          autostart = true;
        };
        pyright = {
          enable = true;
        };
        lua_ls = {
          enable = true;
          settings.telemetry.enable = false;
        };
        ts_ls = {
          enable = true; # TS
          filetypes = [
            "typescript"
            "typescriptreact"
            "typescript.tsx"
          ];
        };
        cssls.enable = true;
        tailwindcss.enable = true;
        html.enable = true;

      };

    };

    lspkind = {
      enable = true;
      settings = {
        cmp = {
          enable = true;
          menu = {
            nvim_lsp = "[LSP]";
            nvim_lua = "[api]";
            path = "[path]";
            luasnip = "[snip]";
            buffer = "[buffer]";
          };
        };
      };
    };

  };

}

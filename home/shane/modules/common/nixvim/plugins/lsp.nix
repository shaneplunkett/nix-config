{ ... }:
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
      keymaps = {
        silent = true;
        diagnostic = {
          "<leader>k" = "open_float";
          "[d" = "goto_prev";
          "]d" = "goto_next";
        };
        lspBuf = {
          "K" = "hover";
          "<leader>ca" = "code_action";
          "<leader>rn" = "rename";
          "<leader>f" = "format";
        };
      };
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
          enable = true;
        };
        cssls.enable = true;
        tailwindcss.enable = true;
        html.enable = true;
        bashls.enable = true;
        astro.enable = true;
        dockerls.enable = true;
        terraformls.enable = true;
        jsonls.enable = true;
        eslint.enable = true;
        yamlls.enable = true;
        phpactor.enable = true;
        ruby_lsp.enable = true;
        sqls.enable = true;
        glsl_analyzer.enable = true;

      };

    };

  };

}

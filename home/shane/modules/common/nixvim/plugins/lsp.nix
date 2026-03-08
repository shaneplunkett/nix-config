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
      inlayHints = false;
      keymaps = {
        silent = true;
        lspBuf = {
          "<leader>cr" = {
            action = "rename";
            desc = "Rename";
          };
        };
      };
      servers = {

        nixd = {
          enable = true;
          settings = {
            formatting.command = [ "nixfmt" ];
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
        # Disable ts_ls in favor of vtsls
        ts_ls = {
          enable = false;
        };
        # Experimental microsoft Go implementation - disabled for stability
        tsgo = {
          enable = false;
        };
        # High performance Typescript LSP (wrapper around VSCode's TS service)
        vtsls = {
          enable = true;
          # Recommended settings for web dev
          settings = {
            typescript = {
              updateImportsOnFileMove.enabled = "always";
              inlayHints = {
                parameterNames.enabled = "literals";
                parameterTypes.enabled = true;
                variableTypes.enabled = false;
                propertyDeclarationTypes.enabled = true;
                functionLikeReturnTypes.enabled = true;
                enumMemberValues.enabled = true;
              };
            };
            javascript = {
              updateImportsOnFileMove.enabled = "always";
              inlayHints = {
                parameterNames.enabled = "literals";
                parameterTypes.enabled = true;
                variableTypes.enabled = false;
                propertyDeclarationTypes.enabled = true;
                functionLikeReturnTypes.enabled = true;
                enumMemberValues.enabled = true;
              };
            };
            vtsls = {
              enableMoveToFileCodeAction = true;
              autoUseWorkspaceTsdk = true;
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true;
                };
              };
            };
          };
        };
        cssls = {
          enable = true;
          settings = {
            css = {
              validate = true;
              lint = {
                unknownAtRules = "ignore";
              };
            };
            scss = {
              validate = true;
              lint = {
                unknownAtRules = "ignore";
              };
            };
            less = {
              validate = true;
              lint = {
                unknownAtRules = "ignore";
              };
            };
          };
        };
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
        prismals = {
          enable = true;
          package = pkgs.prisma-language-server;
        };
        glsl_analyzer.enable = true;

        sourcekit = {
          enable = pkgs.stdenv.isDarwin;
          cmd = [
            "xcrun"
            "sourcekit-lsp"
          ];
          filetypes = [
            "swift"
            "objc"
            "objcpp"
          ];
        };

      };

    };

  };

}

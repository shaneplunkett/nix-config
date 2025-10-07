{ pkgs, ... }:
{
  extraPackages = with pkgs; [
    prettier
    biome
    black
    ruff
    shfmt
    stylua
    rustfmt
    sqlfluff
    nixfmt
    hadolint
    rubocop
    gofumpt
    goimports-reviser

  ];

  plugins = {

    conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          "_" = [ "trim_whitspace" ];
          css = [ "biome" ];
          html = [ "biome" ];
          svg = [ "biome" ];
          fish = [ "fish_indent" ];
          javascript = [ "prettier" ];
          javascriptreact = [ "prettier" ];
          json = [ "prettier" ];
          jsonc = [ "prettier" ];
          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
          mdx = [ "prettier" ];
          markdown = [ "prettier" ];
          python = [ "black" "ruff" ]; # Both black and ruff for Python
          sh = [ "shfmt" ];
          bash = [ "shfmt" ];
          svelte = [ "prettier" ];
          typescript = [ "prettier" ];
          typescriptreact = [ "prettier" ];
          rust = [ "rustfmt" ];
          go = [ "gofmt" "goimports" ];
          astro = [ "prettier" ];
          terraform = [ "terraform_fmt" ];
          tf = [ "terraform_fmt" ];
          sql = [ "sqlfluff" ];
          pgsql = [ "sqlfluff" ];
          yaml = [ "prettier" ];
          yml = [ "prettier" ];
          ruby = [ "rubocop" ];
          php = [ "php_cs_fixer" ];
          dockerfile = [ "hadolint" ];
          glsl = [ "clang_format" ];
        };
        format_on_save = ''
          function(bufnr)
          local ignore_filetypes = { "helm" }
          if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
          return
          end

          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
          end

          -- Disable autoformat for files in a certain path
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname:match("/node_modules/") then
          return
          end
          return { timeout_ms = 1000, lsp_fallback = true }
          end
        '';
      };

    };

  };

}

{ pkgs, ... }:
{

  plugins = {

    treesitter = {
      enable = true;
      settings = {
        indent = {
          enable = true;

        };
        highlight.enable = true;
        nixvimInjections = true;
        grammerPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
      };

      nixvimInjections = true;
      nixGrammars = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        css
        eex
        elixir
        erlang
        heex
        html
        hyprlang
        javascript
        nix
        python
        svelte
        typescript
        tsx
        terraform
        hcl
        astro
        rust
        ruby
        sql
        glimmer
        c_sharp
        glsl
        prisma

      ];
    };

    treesitter-context = {
      enable = true;
    };

    treesitter-textobjects = {
      enable = true;
      settings = {
        select = {
          enable = true;
          lookahead = true;
        };
      };
    };
    extraConfigLua = ''
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    '';
  };

}

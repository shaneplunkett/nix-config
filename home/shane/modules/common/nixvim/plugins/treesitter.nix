{ pkgs, ... }:
{
  plugins = {
    treesitter = {
      enable = true;

      settings = {
        indent = {
          enable = true;
        };
        highlight = {
          enable = true;
        };
      };

      nixvimInjections = true;
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
        terraform
        hcl
        astro
        rust
        ruby
        sql
        glimmer
        c_sharp
        glsl

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
  };
}

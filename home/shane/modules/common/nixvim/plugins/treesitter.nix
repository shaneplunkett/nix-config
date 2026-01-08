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
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
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


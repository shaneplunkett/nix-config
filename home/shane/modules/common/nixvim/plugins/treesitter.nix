{ pkgs, ... }:
{

  plugins = {

    treesitter-context.enable = false;
    treesitter-textobjects = {
      enable = true;
      select = {
        enable = true;
        lookahead = true;
      };
    };
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

    };

  };
}

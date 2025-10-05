{ pkgs, ... }:
{

  plugins = {

    neo-tree = {
      enable = true;
      window.mappings = {
        "\\" = "close_window";
        "l" = "open";
        "h" = "close_node";

      };

    };

  };
}

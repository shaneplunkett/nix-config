{ pkgs, ... }:
{
  plugins = {
    which-key = {
      enable = true;
      settings = {
        spec = [
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
          }
          {
            __unkeyed-1 = "<leader>o";
            group = "OpenCode";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "Search/Symbols";
          }
          {
            __unkeyed-1 = "<leader>d";
            group = "Document/Debug";
          }
          {
            __unkeyed-1 = "<leader>w";
            group = "Workspace";
          }
          {
            __unkeyed-1 = "<leader>x";
            group = "Trouble";
          }
          {
            __unkeyed-1 = "<leader>c";
            group = "Code";
          }
          {
            __unkeyed-1 = "g";
            group = "Goto";
          }
        ];
      };
    };
  };
}

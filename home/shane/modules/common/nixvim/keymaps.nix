{ ... }:
{
  keymaps = [
    {
      mode = "i";
      key = "jj";
      action = "<Esc>";
      options.desc = "Exit insert mode";
    }
    {
      mode = "n";
      key = "\\";
      action = ":Neotree toggle right<CR>";
      options.desc = "NeoTree toggle";
    }
    {
      mode = "n";
      key = "gx";
      action.__raw = "function() vim.ui.open(vim.fn.expand('<cfile>')) end";
      options.desc = "Open with system app";
    }
  ];

}

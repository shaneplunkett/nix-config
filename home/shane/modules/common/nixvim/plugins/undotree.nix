{ ... }:
{
  plugins.undotree = {
    enable = true;
    settings = {
      WindowLayout = 2;
      DiffAutoOpen = true;
      SetFocusWhenToggle = true;
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>u";
      action = "<cmd>UndotreeToggle<CR>";
      options.desc = "Toggle Undotree";
    }
  ];
}

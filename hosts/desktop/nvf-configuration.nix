{
  pkgs,
  lib,
  ...
}: {
  vim = {
    theme = {
      enable = true;
      name = "catppuccin";
      style = "frappe";
    };
    statusline.lualine.enable = true;
    telescope.enable = true;
    autocomplete.nvim-cmp.enable = true;

    filetree = {
      neo-tree = {
        enable = true;
      };
    };

    utility = {
      snacks-nvim = {
        enable = true;
      };
    };
    languages = {
      enableLSP = true;
      enableTreesitter = true;

      nix.enable = true;
      go.enable = true;
      ts.enable = true;
    };
  };
}

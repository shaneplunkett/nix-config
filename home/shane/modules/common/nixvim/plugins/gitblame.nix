{ pkgs, ... }:
{
  plugins = {
    gitblame = {
      enable = true;
      settings = {
        # Disable by default - only show when triggered
        enabled = false;
        # Date format matching your old config
        date_format = "%Y %b %d";
      };
    };
  };
  
  keymaps = [
    {
      mode = "n";
      key = "<leader>gB";
      action = ":GitBlameToggle<CR>";
      options.desc = "Git Blame";
    }
  ];
}

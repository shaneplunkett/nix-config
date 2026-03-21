{ ... }:
{
  plugins.markview = {
    enable = true;
    settings = {
      markdown = {
        headings = {
          heading_1 = { style = "icon"; icon = "◈ "; sign = false; };
          heading_2 = { style = "icon"; icon = "◆ "; sign = false; };
          heading_3 = { style = "icon"; icon = "◇ "; sign = false; };
          heading_4 = { style = "icon"; icon = "○ "; sign = false; };
          heading_5 = { style = "icon"; icon = "• "; sign = false; };
          heading_6 = { style = "icon"; icon = "· "; sign = false; };
          setext_1 = { style = "decorated"; sign = false; };
          setext_2 = { style = "decorated"; sign = false; };
        };
        code_blocks = {
          sign = false;
          label_direction = "right";
        };
      };
    };
  };

  # Word-boundary wrapping and narrow sign column for markdown files
  autoCmd = [
    {
      event = "FileType";
      pattern = [ "markdown" ];
      callback.__raw = ''
        function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.breakindent = true
          vim.opt_local.signcolumn = "no"
        end
      '';
    }
  ];
}

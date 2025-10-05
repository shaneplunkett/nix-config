{ self, ... }:
{
  opts = {
    number = true;
    relativenumber = true;
    mouse = "a";
    clipboard = "unnamedplus";
    winborder = "rounded";
    tabstop = 4;
    shiftwidth = 4;
    expandtab = true;
    showmode = false;
    breakindent = true;
    undofile = true;
    ignorecase = true;
    smartcase = true;
    textwidth = 0;
    wrap = true;
    signcolumn = "yes:3";
    colorcolumn = "81";
    updatetime = 250;
    timeoutlen = 300;
    splitright = true;
    splitbelow = true;
    list = true;
    listchars.__raw = "{ tab = '» ', trail = '·', nbsp = '␣' }";
    inccommand = "split";
    cursorline = true;
    scrolloff = 999;
    
    # Disable built-in completion to prevent dual UI
    completeopt = "menu,menuone,noselect";

  };
}

{ pkgs, ... }: {

programs.neovim = {
enable = true;
defaultEditor = true;
viAlias  = true;
vimAlias = true;
vimdiffAlias = true;
coc.enable = true;
withNodeJs = true;

extraLuaPackages = ps: [
ps.lua
ps.luarocks-nix
ps.magick

];

extraPackages = with pkgs; [

ripgrep
fd
lazygit
fzf

lua-language-server
nixd
nil

nixfmt-rfc-style
shfmt
black
sylua

];

};

home.file "./.config/nvim/" {
source = ./nvim;
recursive = true;

};
}

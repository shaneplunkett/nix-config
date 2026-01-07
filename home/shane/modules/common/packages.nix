{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    jq
    bat
    lsd
    lazygit
    starship
    obsidian
    go
    lazydocker
  ];
}

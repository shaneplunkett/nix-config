{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    jq
    bat
    lsd
    lazygit
    starship
    obsidian
    vesktop
    go
    lazydocker
  ];
}

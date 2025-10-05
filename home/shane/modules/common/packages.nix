{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # General CLI tools
    jq
    bat
    lsd
    lazygit
    starship
    neofetch
    obsidian
    vesktop
    go
    lazydocker
    opencode

  ];
}

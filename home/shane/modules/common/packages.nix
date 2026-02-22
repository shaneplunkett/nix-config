{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    jq
    fd
    bat
    lsd
    lazygit
    starship
    obsidian
    go
    lazydocker
    google-cloud-sdk
    terraform
    opencode
    ripgrep
    tealdeer
    zoxide
    fzf
  ];
}

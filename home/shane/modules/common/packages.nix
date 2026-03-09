{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jq
    fd
    bat
    lsd
    lazycommit
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

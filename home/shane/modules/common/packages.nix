{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jq
    fd
    lazycommit
    lazygit
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

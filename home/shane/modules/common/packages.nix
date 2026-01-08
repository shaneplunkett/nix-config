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
    gemini-cli
    zed-editor
  ];
}

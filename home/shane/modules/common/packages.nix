{ pkgs, inputs, ... }:
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
    ripgrep
    tealdeer
    zoxide
    fzf
    inputs.gws.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jq
    fd
    lazygit
    obsidian
    go
    lazydocker
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    kubectx
    terraform
    tflint
    tftui
    terraform-docs
    infracost
    ripgrep
    tealdeer
    fzf
    pre-commit

    nix-output-monitor
    nvd
    statix
    deadnix
    manix
    nurl
    nix-init
  ];
}

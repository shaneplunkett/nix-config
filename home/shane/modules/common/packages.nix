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
    kubectx # ships kubectx + kubens binaries together
    terraform
    tflint
    tftui
    terraform-docs
    infracost
    ripgrep
    tealdeer
    zoxide
    fzf
    pre-commit
    # gws now arrives via vex-tooling's homeManagerModule.
  ];
}

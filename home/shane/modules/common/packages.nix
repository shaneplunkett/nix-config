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
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    kubectx # ships kubectx + kubens binaries together
    terraform
    ripgrep
    tealdeer
    zoxide
    fzf
    inputs.gws.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

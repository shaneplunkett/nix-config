{ lib, pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
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
      bitwarden-desktop
      nix-output-monitor
      nvd
      statix
      deadnix
      manix
      nurl
      nix-init
      nix-update
    ]
    # Linux gets slack-themed (Catppuccin) from the linux module instead.
    ++ lib.optionals stdenv.isDarwin [ slack ];
}

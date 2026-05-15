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

    # Nix QoL — nh comes from programs.nh.enable in nh.nix.
    nix-output-monitor # nom — prettier nix build output (tree view)
    nvd # version diff between generations, shown after every switch
    statix # nix linter (anti-patterns)
    deadnix # find dead let-bindings / function args
    comma # `, <cmd>` runs anything from nixpkgs without installing
    manix # local search across nixpkgs + home-manager + nixos options
  ];
}

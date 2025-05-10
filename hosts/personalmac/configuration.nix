{ config, pkgs, ... }:

{
  environment.systemPackages =
    [ pkgs.vim
    ];

  programs.fish.enable = true;
    nix.settings.experimental-features = "nix-command flakes";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}

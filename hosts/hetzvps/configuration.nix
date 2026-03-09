{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking-hetzner.nix
    ./modules
    ../../modules/common
    ../../modules/nixos/docker.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/maintenance.nix
  ];

  system.stateVersion = "23.11";
}

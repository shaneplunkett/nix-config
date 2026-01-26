{ inputs, ... }:
{
  imports = [
    ./audio.nix
    ./fonts.nix
    ./gaming.nix
    ./hardware-configuration.nix
    ./hardware-custom.nix
    ./locale.nix
    ./networking.nix
    ./packages.nix
    ./programs.nix
    ./services.nix
    ./storage.nix
    ./user.nix
    inputs.home-manager.nixosModules.default
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}

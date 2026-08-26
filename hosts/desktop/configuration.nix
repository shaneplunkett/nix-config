{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./modules
    ../../modules/common
    ../../modules/nixos
    inputs.home-manager.nixosModules.default
    inputs.nix-config-private.nixosModules.default
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      editor = false;
    };
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "24.11";
}

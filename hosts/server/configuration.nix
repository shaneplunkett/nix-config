{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/nixos/locale.nix
    ../../modules/nixos/maintenance.nix
    inputs.home-manager.nixosModules.default
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "mcphub";

  users.users.shane = {
    isNormalUser = true;
    description = "Shane Plunkett";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfq31bP+xQwlO/joZeGU6LaLYZXV2ql7TLSv5ToVUtJ"
    ];
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  security.sudo.wheelNeedsPassword = false;

  networking.firewall.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}

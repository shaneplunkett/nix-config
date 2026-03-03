{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./modules
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

  # Dynamic linker compat for tools like esbuild, uv-managed python, etc.
  programs.nix-ld.enable = true;

  # System packages — needed globally so #!/usr/bin/env node works in spawned scripts
  environment.systemPackages = with pkgs; [
    nodejs
    pnpm
    git
    uv
    jq
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "shane" ];
  };

  system.stateVersion = "24.11";
}

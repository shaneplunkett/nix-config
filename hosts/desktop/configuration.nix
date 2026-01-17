{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./hardware-custom.nix
    ./hyprland.nix
    ./gaming.nix
    ./audio.nix
    ./storage.nix
    ./fonts.nix
    inputs.home-manager.nixosModules.default
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop";
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Australia/Melbourne";
  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  services.teamviewer = {
    enable = true;
  };

  services.flatpak.enable = true;

  users.users.shane = {
    isNormalUser = true;
    description = "Shane Plunkett";
    extraGroups = [
      "networkmanager"
      "dialout"
      "wheel"
    ];
  };

  # System services
  nixpkgs.config.allowUnfree = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    home-manager
    gh
    gcc
    zip
    unzip
    psmisc
  ];

  system.stateVersion = "24.11";
}

{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop";
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

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

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      nerd-fonts.mononoki
    ];
  };
  services.teamviewer = {
    enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-mocha";
    package = pkgs.kdePackages.sddm;
  };
  services.displayManager.sddm.wayland.enable = true;
  programs.hyprland = {
    enable = true;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.shane = {
    isNormalUser = true;
    description = "Shane Plunkett";
    extraGroups = [
      "networkmanager"
      "dialout"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };
  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  fileSystems."home/shane/unraid/programs" = {
    device = "//192.168.1.132/Programs";
    fsType = "cifs";
    options = [
      "guest"
      "uid=1000"
      "gid=100" # Replace with your GID
      "vers=3.0"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "nofail"
    ];
  };
  fileSystems."home/shane/unraid/media" = {
    device = "//192.168.1.132/media";
    fsType = "cifs";
    options = [
      "guest"
      "uid=1000"
      "gid=100" # Replace with your GID
      "vers=3.0"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "nofail"
    ];
  };

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  programs.fish.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  programs.xfconf.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  nixpkgs.config.allowUnfree = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    bitwarden-cli
    git
    wget
    home-manager
    mangohud
    gh
    hyprpolkitagent
    gcc
    wl-clipboard
    zip
    unzip
    lutris
    heroic
    teamviewer
    psmisc
    (catppuccin-sddm.override {
      flavor = "mocha";
      font = "Mononoki Nerd Font";
      fontSize = "14";
      loginBackground = false;
    })
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_LAYER = "1";
    MOZ_ENABLE_WAYLAND = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };

  system.stateVersion = "24.11";
}

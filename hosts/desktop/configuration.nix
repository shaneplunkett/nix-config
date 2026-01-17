{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./hyprland.nix
    ./gaming.nix
    inputs.home-manager.nixosModules.default
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
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

  services.flatpak.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "soft";
      value = "4096";
    }
    {
      domain = "*";
      item = "nofile";
      type = "hard";
      value = "8192";
    }
  ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  systemd.user.services.pipewire-pulse.wantedBy = [ "pipewire.service" ];
  users.users.shane = {
    isNormalUser = true;
    description = "Shane Plunkett";
    extraGroups = [
      "networkmanager"
      "dialout"
      "wheel"
    ];
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
  fileSystems."home/shane/unraid/appdata" = {
    device = "//192.168.1.132/appdata";
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
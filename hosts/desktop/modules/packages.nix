{ pkgs, ... }:
{

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
    hyprpolkitagent
    wl-clipboard
    tuigreet
    nemo-with-extensions
    file-roller
    openocd
  ];

}

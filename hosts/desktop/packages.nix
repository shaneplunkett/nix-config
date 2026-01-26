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
    thunar-archive-plugin
    thunar-volman
  ];

}

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    home-manager
    htop
    unzip
    zip
  ];
}

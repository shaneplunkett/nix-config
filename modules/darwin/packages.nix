{ pkgs, ... }:
{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    vim
    alt-tab-macos
    chatgpt
    colima
    docker
    docker-buildx
    docker-compose
    home-manager
    hidden-bar
    postman
    raycast
    signal-desktop
    ytmdesktop
    google-chrome
    gh
    jankyborders
  ];
}

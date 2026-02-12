{ pkgs, ... }:
{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    vim
    mkalias
    alt-tab-macos
    home-manager
    raycast
    ytmdesktop
    google-chrome
    signal-desktop-bin
    gh
    jankyborders
  ];
  nixpkgs.config.permittedInsecurePackages = [
    "google-chrome-144.0.7559.97"
  ];
}

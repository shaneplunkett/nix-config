{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    heroic
    wineWow64Packages.stagingFull
    winetricks
    protontricks
    bottles
    umu-launcher
  ];
}

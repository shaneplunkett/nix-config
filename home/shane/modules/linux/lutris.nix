{ pkgs, osConfig, ... }:
{
  programs.lutris = {
    enable = true;
    winePackages = [ pkgs.wineWow64Packages.stagingFull ];
    protonPackages = [ pkgs.proton-ge-bin ];
    extraPackages = with pkgs; [
      mangohud
      winetricks
      gamemode
      umu-launcher
    ];
    steamPackage = osConfig.programs.steam.package;
  };
}

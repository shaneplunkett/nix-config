{ pkgs, inputs, ... }:
let
  nix-gaming = inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    lutris
    heroic
    nix-gaming.wine-ge
    nix-gaming.umu-launcher-git
    nix-gaming.winetricks-git
    pkgs.endfield
  ];
}

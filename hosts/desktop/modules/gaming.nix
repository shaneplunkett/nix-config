{ pkgs, inputs, ... }:
{
  imports = [ inputs.aagl.nixosModules.default ];

  nix.settings = inputs.aagl.nixConfig;

  programs.sleepy-launcher.enable = true; # Zenless Zone Zero
  programs.anime-game-launcher.enable = true; # Genshin Impact
  programs.wavey-launcher.enable = true; # Wuthering Waves

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [
      inputs.dw-proton.packages.${pkgs.stdenv.hostPlatform.system}.dw-proton
    ];
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

{ pkgs, inputs, ... }:
{
  imports = [ inputs.aagl.nixosModules.default ];

  nix.settings = inputs.aagl.nixConfig;

  programs = {
    sleepy-launcher.enable = true;
    anime-game-launcher.enable = true;
    wavey-launcher.enable = true;

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [
        # Temporarily disabled: upstream Dawn Wine fetch is stalling during rebuilds.
        # inputs.dw-proton.packages.${pkgs.stdenv.hostPlatform.system}.dw-proton
      ];
    };
    gamemode.enable = true;
  };

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

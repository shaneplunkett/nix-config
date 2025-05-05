{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./modules/hyprland.nix
    ./modules/waybar.nix
    ./modules/packages.nix
    ./modules/fish.nix
    ./modules/rofi.nix
    ./modules/dunst.nix
  ];

  home.username = "shane";
  home.homeDirectory = "/home/shane";

  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.sessionVariables = {
    EDITOR = "nvim";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.home-manager.enable = true;
}

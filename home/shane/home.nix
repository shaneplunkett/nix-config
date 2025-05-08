{
  config,
  pkgs,
  ...
}:

{

  home.username = "shane";
  home.homeDirectory = "/home/shane";

  imports = [
    ./modules/common/btop.nix
    ./modules/common/catppuccin.nix
    ./modules/common/cava.nix
    ./modules/common/direnv.nix
    ./modules/common/fish.nix
    ./modules/common/ghostty.nix
    ./modules/common/neovim.nix
    ./modules/common/starship.nix
    ./modules/common/packages.nix
    ./modules/common/tmux.nix

    ./modules/linux/dunst.nix
    ./modules/linux/hyprland.nix
    ./modules/linux/hyprpaper.nix
    ./modules/linux/rofi.nix
    ./modules/linux/theme.nix
    ./modules/linux/waybar.nix
    ./modules/linux/packages.nix
  ];

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

}

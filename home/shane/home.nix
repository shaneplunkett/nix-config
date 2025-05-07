{
  config,
  pkgs,
  lib,
  ...
}:

let
  system = pkgs.system;
  isLinux = lib.hasPrefix "x86_64-linux" system;
  isDarwin = lib.hasPrefix "aarch-darwin" system || lib.hasPrefex "x86_64-darwin" system;
  username = "shane";
  homedir = if isLinux then "/home/${username}" else "/Users/${username}";
in
{

  home.username = "shane";
  home.homeDirectory = homedir;

  imports =
    #Common
    [
      ./modules/common/btop.nix
      ./modules/common/catppuccin.nix
      ./modules/common/cava.nix
      ./modules/common/direnv.nix
      ./modules/common/fish.nix
      ./modules/common/ghostty.nix
      ./modules/common/neovim.nix
      ./modules/common/starship.nix
      ./modules/common/packages.nix

    ]
    ++ lib.optionals isLinux [
      ./modules/linux/dunst.nix
      ./modules/linux/hyprland.nix
      ./modules/linux/hyprpaper.nix
      ./modules/linux/rofi.nix
      ./modules/linux/theme.nix
      ./modules/linux/waybar.nix
      ./modules/linux/packages.nix
    ]
    ++ lib.optionals isDarwin [ ];

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

}

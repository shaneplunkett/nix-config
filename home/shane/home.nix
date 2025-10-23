{
  config,
  ...
}:
{

  imports = [
    ./modules/common/btop.nix
    ./modules/common/cava.nix
    ./modules/common/direnv.nix
    ./modules/common/fish.nix
    ./modules/common/nixvim
    ./modules/common/starship.nix
    ./modules/common/packages.nix
    ./modules/common/tmux.nix
    ./modules/common/git.nix

    ./modules/linux/swaync.nix
    ./modules/linux/ghostty.nix
    ./modules/linux/hyprland.nix
    ./modules/linux/hyprpaper.nix
    ./modules/linux/hyprpanel
    ./modules/linux/rofi/rofi.nix
    ./modules/linux/theme.nix
    ./modules/linux/waybar.nix
    ./modules/linux/packages.nix
    ./modules/linux/webapps
  ];

  home.username = "shane";
  home.homeDirectory = "/home/shane";
  xdg = {
    userDirs = {
      createDirectories = true;
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      videos = "${config.home.homeDirectory}/videos";
      templates = "${config.home.homeDirectory}/templates";
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/screenshots";
      };
    };
  };
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

}

{
  config,
  pkgs,
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

    ./modules/linux/dunst.nix
    ./modules/linux/ghostty.nix
    ./modules/linux/hyprland.nix
    ./modules/linux/hyprpaper.nix
    ./modules/linux/rofi.nix

    ./modules/linux/waybar.nix
    ./modules/linux/packages.nix
    ./modules/linux/stylix.nix
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

  # Stylix configuration
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
    
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.mononoki;
        name = "Mononoki Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.mononoki;
        name = "Mononoki Nerd Font";
      };
      serif = {
        package = pkgs.nerd-fonts.mononoki;
        name = "Mononoki Nerd Font";
      };
      sizes = {
        applications = 12;
        terminal = 16;
        desktop = 12;
        popups = 12;
      };
    };
    
    cursor = {
      package = pkgs.catppuccin-cursors.mochaLavender;
      name = "catppuccin-mocha-lavender-cursors";
      size = 16;
    };
    
    opacity = {
      applications = 1.0;
      terminal = 0.95;
      desktop = 1.0;
      popups = 1.0;
    };
  };
}

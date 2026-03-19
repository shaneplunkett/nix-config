{ lib, compositor, shell, ... }:
{

  imports = [

    # Always loaded
    ./theme.nix
    ./packages.nix
    ./webapps
    ./claude-desktop.nix

  ]

  # Compositor
  ++ lib.optionals (compositor == "hyprland") [
    ./hyprland.nix
  ]
  ++ lib.optionals (compositor == "niri") [
    ./niri.nix
  ]

  # Shell
  ++ lib.optionals (shell == "hyprpanel") [
    ./hyprpanel
    ./hyprpaper.nix
    ./rofi/rofi.nix
    ./wallpaper.nix
  ]
  ++ lib.optionals (shell == "noctalia") [
    ./noctalia.nix
  ];

}

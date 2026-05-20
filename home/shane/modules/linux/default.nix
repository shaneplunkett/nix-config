{
  lib,
  compositor,
  shell,
  ...
}:
{

  imports = [

    ./theme.nix
    ./packages.nix
    ./webapps
    ./heroic.nix
    ./vesktop.nix
    ./lutris.nix
    ./waydroid.nix

  ]

  ++ lib.optionals (compositor == "hyprland") [
    ./hyprland.nix
  ]
  ++ lib.optionals (compositor == "niri") [
    ./niri.nix
  ]

  ++ lib.optionals (shell == "hyprpanel") [
    ./hyprpanel
    ./hyprpaper.nix
    ./rofi/rofi.nix
  ]
  ++ lib.optionals (shell == "noctalia") [
    ./noctalia.nix
  ];

}

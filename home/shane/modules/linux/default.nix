{
  inputs,
  lib,
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
    ./hyprland.nix
    inputs.codex-desktop-linux.homeManagerModules.default

  ]

  ++ lib.optionals (shell == "noctalia") [
    ./noctalia.nix
  ];

}

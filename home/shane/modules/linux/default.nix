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
    ./bloodborne.nix
    ./webapps
    ./heroic.nix
    ./vesktop.nix
    ./lutris.nix
    ./waydroid.nix
    ./hyprland.nix
    ./taildrop.nix
    inputs.codex-desktop-linux.homeManagerModules.default

  ]

  ++ lib.optionals (shell == "noctalia") [
    ./noctalia.nix
  ];

}

{
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

  ]

  ++ lib.optionals (shell == "noctalia") [
    ./noctalia.nix
  ];

}

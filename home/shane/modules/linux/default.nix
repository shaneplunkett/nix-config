{
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
    ./vesktop.nix
    ./waydroid.nix
    ./hyprland.nix
    ./taildrop.nix
  ]

  ++ lib.optionals (shell == "noctalia") [
    ./noctalia.nix
  ];

}

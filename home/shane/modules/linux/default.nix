{
  lib,
  shell,
  ...
}:
{

  imports = [

    ./theme.nix
    ./packages.nix
    ./linear.nix
    ./bloodborne.nix
    ./vesktop.nix
    ./waydroid.nix
    ./hyprland.nix
    ./taildrop.nix
    ./screen-share.nix
  ]

  ++ lib.optionals (shell == "noctalia") [
    ./noctalia.nix
    ./noctalia-v5.nix
  ];

}

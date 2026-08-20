{
  lib,
  shell,
  ...
}:
{

  imports = [

    ./theme.nix
    ./packages.nix
    ./granola.nix
    ./linear.nix
    ./bloodborne.nix
    ./webapps
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

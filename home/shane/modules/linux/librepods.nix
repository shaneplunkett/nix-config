{ inputs, pkgs, ... }:
let
  librepods = inputs.librepods.packages.${pkgs.system}.default;
  librepodsSrc = inputs.librepods;
in
{
  home.packages = [ librepods ];

  xdg.desktopEntries.librepods = {
    name = "LibrePods";
    comment = "AirPods manager for Linux";
    exec = "librepods";
    icon = "${librepodsSrc}/linux-rust/assets/icon.png";
    terminal = false;
    type = "Application";
    categories = [ "Utility" "Audio" ];
  };
}

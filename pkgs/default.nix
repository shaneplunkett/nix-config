{
  pkgs,
  vexCodeSrc,
  isLinux ? false,
  isX86Linux ? false,
}:
let
  optionalAttrs = condition: attrs: if condition then attrs else { };
in
{
  vex-code = pkgs.callPackage ./vex-code { src = vexCodeSrc; };
  xcodebuild-nvim = pkgs.callPackage ./xcodebuild-nvim { };
}
// optionalAttrs isLinux {
  bluebubbles-themed = pkgs.callPackage ./bluebubbles-themed {
    palette = import ../lib/palette.nix;
  };
  hyprland-preview-share-picker = pkgs.callPackage ./hyprland-preview-share-picker { };
}
// optionalAttrs isX86Linux {
  linear-desktop = pkgs.callPackage ./linear-desktop { };
  orca-studio = pkgs.callPackage ./orca-studio { };
  shadps4-cache-fixed = pkgs.callPackage ./shadps4-cache-fixed { };
  ytmdesktop-bin = pkgs.callPackage ./ytmdesktop-bin { };
}

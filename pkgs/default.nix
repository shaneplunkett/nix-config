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
  claude-plugins-official = pkgs.callPackage ./claude-plugins-official { };
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
  granola = pkgs.callPackage ./granola { };
  linear-desktop = pkgs.callPackage ./linear-desktop { };
  slack-themed = pkgs.callPackage ./slack-themed { };
  orca-slicer-bambulab = pkgs.callPackage ./orca-slicer-bambulab { };
  shadps4-cache-fixed = pkgs.callPackage ./shadps4-cache-fixed { };
  ytmdesktop-bin = pkgs.callPackage ./ytmdesktop-bin { };
}

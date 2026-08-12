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
}
// optionalAttrs isX86Linux {
  granola = pkgs.callPackage ./granola { };
  orca-slicer-bambulab = pkgs.callPackage ./orca-slicer-bambulab { };
  shadps4-cache-fixed = pkgs.callPackage ./shadps4-cache-fixed { };
  ytmdesktop-bin = pkgs.callPackage ./ytmdesktop-bin { };
}

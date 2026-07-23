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
  aikido-mcp = pkgs.callPackage ./aikido-mcp { };
  claude-plugins-official = pkgs.callPackage ./claude-plugins-official { };
  linear-cli = pkgs.callPackage ./linear-cli { };
  vex-code = pkgs.callPackage ./vex-code { src = vexCodeSrc; };
  xcodebuild-nvim = pkgs.callPackage ./xcodebuild-nvim { };
  xero-mcp-server = pkgs.callPackage ./xero-mcp-server { };
}
// optionalAttrs isLinux {
  bluebubbles-themed = pkgs.callPackage ./bluebubbles-themed { };
}
// optionalAttrs isX86Linux {
  orca-slicer-bambulab = pkgs.callPackage ./orca-slicer-bambulab { };
  shadps4-cache-fixed = pkgs.callPackage ./shadps4-cache-fixed { };
  ytmdesktop-bin = pkgs.callPackage ./ytmdesktop-bin { };
}

{
  pkgs,
  vexCodeSrc,
  isLinux ? false,
  isX86Linux ? false,
  hasAgentClis ? false,
}:
let
  optionalAttrs = condition: attrs: if condition then attrs else { };
in
{
  roundhog = pkgs.callPackage ./roundhog { };
  vex-code = pkgs.callPackage ./vex-code { src = vexCodeSrc; };
  xcodebuild-nvim = pkgs.callPackage ./xcodebuild-nvim { };
}
// optionalAttrs isLinux {
  bluebubbles = pkgs.callPackage ./bluebubbles { };
  bluebubbles-themed = pkgs.callPackage ./bluebubbles-themed {
    palette = import ../lib/palette.nix;
  };
  hyprland-preview-share-picker = pkgs.callPackage ./hyprland-preview-share-picker { };
}
// optionalAttrs hasAgentClis {
  browserbase-cli = pkgs.callPackage ./browserbase-cli { };
  langsmith-cli = pkgs.callPackage ./langsmith-cli { };
  tavily-cli = pkgs.callPackage ./tavily-cli { };
  todoist-cli = pkgs.callPackage ./todoist-cli { };
  unifi-cli = pkgs.callPackage ./unifi-cli { };
}
// optionalAttrs isX86Linux {
  linear-desktop = pkgs.callPackage ./linear-desktop { };
  slack-themed = pkgs.callPackage ./slack-themed { };
  orca-studio = pkgs.callPackage ./orca-studio { };
  shadps4-cache-fixed = pkgs.callPackage ./shadps4-cache-fixed { };
  ytmdesktop-bin = pkgs.callPackage ./ytmdesktop-bin { };
}

{ pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  programs.ghostty = {
    enable = true;
    package = lib.mkIf isDarwin null; # macOS installed via Homebrew
    enableFishIntegration = true;
    settings = {
      font-family = "Mononoki Nerd Font";
      font-size = if isDarwin then "21" else "16";
      command = if isDarwin then "/etc/profiles/per-user/shane/bin/fish --login --interactive" else "fish --login --interactive";
      theme = "Catppuccin Mocha";
      confirm-close-surface = "false";
    } // lib.optionalAttrs isDarwin {
      macos-titlebar-style = "hidden";
      macos-non-native-fullscreen = true;
    };
  };
}

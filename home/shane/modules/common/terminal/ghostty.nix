{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv) isDarwin;

  fishCommand = "direct:${lib.getExe pkgs.fish} --login --interactive";
in
{
  programs.ghostty = {
    enable = true;
    package = lib.mkIf isDarwin null;
    enableBashIntegration = false;
    enableFishIntegration = true;
    enableZshIntegration = false;

    settings = {
      font-family = "Mononoki Nerd Font";
      font-size = if isDarwin then 21 else 14;
      command = fishCommand;
      shell-integration = "fish";
      shell-integration-features = "cursor,title,ssh-env,ssh-terminfo,path";
      confirm-close-surface = false;
    }
    // lib.optionalAttrs isDarwin {
      macos-titlebar-style = "hidden";
      macos-non-native-fullscreen = true;
      window-save-state = "never";
    };
  };
}

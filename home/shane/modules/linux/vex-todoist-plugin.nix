# Vex Todoist — noctalia-shell plugin deployment
# Source lives in ~/projects/personal/noctalia-plugins/vex-todoist/
{ config, lib, ... }:
let
  pluginDir = "${config.home.homeDirectory}/projects/personal/noctalia-plugins/vex-todoist";
in
{
  home.activation.vexTodoistPlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PLUGIN_DEST="${config.home.homeDirectory}/.config/noctalia/plugins/vex-todoist"
    rm -rf "$PLUGIN_DEST"
    ln -sfn "${pluginDir}" "$PLUGIN_DEST"
  '';

  programs.noctalia-shell.pluginSettings.vex-todoist = {
    accentColor = "primary";
  };
}

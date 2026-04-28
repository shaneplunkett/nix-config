# Vex Claude Usage — noctalia-shell plugin deployment
# Source lives in ~/projects/personal/noctalia-plugins/vex-claude-usage/
{ config, lib, ... }:
let
  pluginDir = "${config.home.homeDirectory}/projects/personal/noctalia-plugins/vex-claude-usage";
in
{
  home.activation.vexClaudeUsagePlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PLUGIN_DEST="${config.home.homeDirectory}/.config/noctalia/plugins/vex-claude-usage"
    rm -rf "$PLUGIN_DEST"
    ln -sfn "${pluginDir}" "$PLUGIN_DEST"
  '';

  programs.noctalia-shell.pluginSettings.vex-claude-usage = {
    accentColor = "primary";
    warningThreshold = 0.7;
    criticalThreshold = 0.9;
    refreshIntervalSec = 300;
  };
}

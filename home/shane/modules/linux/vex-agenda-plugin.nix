# Vex Agenda — noctalia-shell plugin deployment
# Source lives in ~/projects/personal/noctalia-plugins/vex-agenda/
# Replaces the built-in Clock widget with an agenda panel.
{ config, lib, ... }:
let
  pluginDir = "${config.home.homeDirectory}/projects/personal/noctalia-plugins/vex-agenda";
in
{
  # Symlink plugin dir → repo for live editing
  home.activation.vexAgendaPlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PLUGIN_DEST="${config.home.homeDirectory}/.config/noctalia/plugins/vex-agenda"
    rm -rf "$PLUGIN_DEST"
    ln -sfn "${pluginDir}" "$PLUGIN_DEST"
  '';

  # Plugin default settings
  programs.noctalia-shell.pluginSettings.vex-agenda = {
    clockColor = "tertiary";
    clockFormat = "HH:mm ddd, MMM dd";
  };
}

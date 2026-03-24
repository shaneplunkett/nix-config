# Vex Agenda — noctalia-shell plugin deployment
# Source lives in ~/projects/personal/noctalia-plugins/vex-agenda/
# Replaces the built-in Clock widget with an agenda panel.
{ pkgs, config, lib, ... }:
let
  pluginDir = "${config.home.homeDirectory}/projects/personal/noctalia-plugins/vex-agenda";
  papirusIcons = "${pkgs.papirus-icon-theme}/share/icons/Papirus/48x48";
in
{
  # Deploy notification icons to a known path
  home.file.".local/share/vex-icons/calendar.svg".source = "${papirusIcons}/apps/alarm-clock.svg";
  home.file.".local/share/vex-icons/heart.svg".source = "${papirusIcons}/emblems/emblem-favorite.svg";
  home.file.".local/share/vex-icons/todo.svg".source = "${papirusIcons}/apps/korg-todo.svg";

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

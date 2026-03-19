# Vex Timer — noctalia-shell plugin deployment
# Source lives in ~/projects/personal/noctalia-plugins/vex-timer/
# This module symlinks the plugin dir for live QML editing (no rebuild needed
# for plugin changes — just clear QML cache + bounce noctalia).
{ pkgs, lib, config, ... }:
let
  soundDir = "${config.home.homeDirectory}/.local/share/vex-timer/sounds";
  pluginDir = "${config.home.homeDirectory}/projects/personal/noctalia-plugins/vex-timer";
in
{
  # ── Sound file — nix manages the store path ──
  home.file.".local/share/vex-timer/sounds/complete.oga".source =
    "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/complete.oga";

  # ── Symlink plugin dir → repo for live editing ──
  # Also substitutes the sound path in Main.qml since that's the only nix-specific bit
  home.activation.vexTimerPlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PLUGIN_DEST="${config.home.homeDirectory}/.config/noctalia/plugins/vex-timer"

    # Remove old managed symlinks/files if they exist
    rm -rf "$PLUGIN_DEST"

    # Symlink to repo
    ln -sfn "${pluginDir}" "$PLUGIN_DEST"

    # Substitute sound path in Main.qml (in-place in the repo)
    ${pkgs.gnused}/bin/sed -i 's|%SOUND_DIR%|${soundDir}|g' "${pluginDir}/Main.qml"
  '';

  # ── Plugin default settings ──
  programs.noctalia-shell.pluginSettings.vex-timer = {
    defaultMinutes = 30;
    iconColor = "secondary";
  };

  # ── Register plugin as enabled ──
  xdg.configFile."noctalia/plugins.json".text = builtins.toJSON {
    version = 2;
    sources = [
      { name = "Noctalia Plugins"; url = "https://github.com/noctalia-dev/noctalia-plugins"; enabled = true; }
    ];
    states = {
      vex-timer = { enabled = true; sourceUrl = "local"; };
    };
  };
}

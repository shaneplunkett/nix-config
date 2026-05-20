{
  config,
  lib,
  pkgs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  pluginRoot = "${homeDir}/projects/personal/noctalia-plugins";
  papirusIcons = "${pkgs.papirus-icon-theme}/share/icons/Papirus/48x48";
  freedesktopSounds = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo";

  plugins = {
    vex-timer = {
      settings = {
        defaultMinutes = 30;
        iconColor = "secondary";
      };
      extraFiles = {
        ".local/share/vex-timer/sounds/complete-chime.oga".source =
          "${freedesktopSounds}/dialog-information.oga";
        ".local/share/vex-timer/sounds/notification.oga".source =
          "${freedesktopSounds}/window-attention.oga";
      };
    };

    vex-agenda = {
      settings = {
        clockColor = "tertiary";
        clockFormat = "HH:mm ddd, MMM dd";
      };
      extraFiles = {
        ".local/share/vex-icons/calendar.svg".source = "${papirusIcons}/apps/alarm-clock.svg";
        ".local/share/vex-icons/heart.svg".source = "${papirusIcons}/emblems/emblem-favorite.svg";
        ".local/share/vex-icons/todo.svg".source = "${papirusIcons}/apps/korg-todo.svg";
      };
    };

    vex-todoist = {
      settings = {
        accentColor = "primary";
      };
    };

    vex-claude-usage = {
      settings = {
        accentColor = "primary";
        warningThreshold = 0.7;
        criticalThreshold = 0.9;
        refreshIntervalSec = 300;
        headlineAccount = "personal";
      };
    };
  };

  pluginExtraFiles = lib.foldl' lib.recursiveUpdate { } (
    lib.mapAttrsToList (_: p: p.extraFiles or { }) plugins
  );
in
{
  home.file = pluginExtraFiles;

  programs.noctalia-shell.pluginSettings = lib.mapAttrs (_: p: p.settings) plugins;

  home.activation.noctaliaPluginSymlinks = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.concatStringsSep "\n" (
      map (name: ''
        $DRY_RUN_CMD rm -rf "${homeDir}/.config/noctalia/plugins/${name}"
        $DRY_RUN_CMD ln -sfn "${pluginRoot}/${name}" "${homeDir}/.config/noctalia/plugins/${name}"
      '') (lib.attrNames plugins)
    )
  );

  _module.args.noctaliaVexPlugins = lib.attrNames plugins;
}

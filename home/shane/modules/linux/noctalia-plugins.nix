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

  chromeExecutable = "${pkgs.google-chrome}/share/google/chrome/google-chrome";
  browserProfileRouter = pkgs.writeShellApplication {
    name = "browser-profile-router";
    text = ''
      if [ "''${1:-}" = "--new-window" ]; then
        if ${lib.getExe config.programs.noctalia-shell.package} ipc call \
          plugin:vex-browser-profile newWindow >/dev/null 2>&1; then
          exit 0
        fi

        exec ${chromeExecutable} --profile-directory=Default --new-window
      fi

      url="''${1:-}"

      if [ -n "$url" ] && ${lib.getExe config.programs.noctalia-shell.package} ipc call \
        plugin:vex-browser-profile open "$url" >/dev/null 2>&1; then
        exit 0
      fi

      args=("--profile-directory=Default")
      if [ -n "$url" ]; then
        args+=("$url")
      fi
      exec ${chromeExecutable} "''${args[@]}"
    '';
  };

  plugins = {
    vex-browser-profile = {
      settings = {
        inherit chromeExecutable;
        personalProfileDirectory = "Default";
        workProfileDirectory = "Profile 1";
        screenName = "DP-2";
      };
    };

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

    vex-tailscale-guard = {
      settings = {
        refreshIntervalMs = 5000;
        workTailnet = "autograb.com.au";
        workAccountPattern = "autograb.com.au";
        workAcceptRoutes = true;
        personalAcceptRoutes = false;
      };
    };

    screen-shot-and-record = {
      settings = {
        enableCross = true;
        enableWindowsSelection = true;
        screenshotEditor = "swappy";
        keepSourceScreenshot = false;
        savePath = "~/Pictures/Screenshots";
        recordingSavePath = "~/Videos/Screen Recordings";
        recordingNotifications = true;
      };
    };
  };

  pluginExtraFiles = lib.foldl' lib.recursiveUpdate { } (
    lib.mapAttrsToList (_: p: p.extraFiles or { }) plugins
  );
in
{
  home.file = pluginExtraFiles;

  xdg = {
    desktopEntries = {
      browser-profile-router = {
        name = "Browser Profile Chooser";
        comment = "Choose which Chrome profile opens an external link";
        exec = "${lib.getExe browserProfileRouter} %u";
        icon = "google-chrome";
        terminal = false;
        noDisplay = true;
        mimeType = [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
      };

      google-chrome = {
        name = "Google Chrome";
        genericName = "Web Browser";
        comment = "Open a new Chrome window in a chosen profile";
        exec = "${lib.getExe browserProfileRouter} --new-window";
        icon = "google-chrome";
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
        settings.StartupWMClass = "google-chrome";
        actions = {
          Personal = {
            name = "New Personal Window";
            exec = "${chromeExecutable} --profile-directory=Default --new-window";
          };
          Work = {
            name = "New Work Window";
            exec = ''${chromeExecutable} --profile-directory="Profile 1" --new-window'';
          };
        };
      };
    };

    mimeApps.defaultApplications = {
      "text/html" = "browser-profile-router.desktop";
      "x-scheme-handler/http" = "browser-profile-router.desktop";
      "x-scheme-handler/https" = "browser-profile-router.desktop";
    };
  };

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

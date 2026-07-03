{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  pluginRoot = "${homeDir}/projects/personal/noctalia-plugins";
  papirusIcons = "${pkgs.papirus-icon-theme}/share/icons/Papirus/48x48";
  freedesktopSounds = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo";

  # tl;dv recorder helper — static Go binary built from the noctalia-plugins flake.
  tldvHelper = "${
    inputs.noctalia-plugins.packages.${pkgs.stdenv.hostPlatform.system}.tldv-helper
  }/bin/tldv-helper";

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

    vex-tailscale-guard = {
      settings = {
        refreshIntervalMs = 5000;
        workTailnet = "autograb.com.au";
        workAccountPattern = "autograb.com.au";
        workAcceptRoutes = true;
        personalAcceptRoutes = false;
      };
    };

    vex-tldv-recorder = {
      settings = {
        accentColor = "primary";
        helperPath = tldvHelper; # static Go binary built from the noctalia-plugins flake
        statusPath = ""; # default XDG_STATE_HOME/vex-tldv-recorder/status.json
        refreshIntervalSec = 30;
      };
      # The tldv:// scheme handler: tl;dv login redirects to tldv://auth?access_token=…,
      # which the OS routes here to hand the token to the helper. Paired with the
      # x-scheme-handler/tldv association in theme.nix's xdg.mimeApps.
      extraFiles = {
        ".local/share/applications/vex-tldv-recorder.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Vex tl;dv Recorder (auth handler)
          Comment=Captures the tldv://auth?access_token=… callback from tl;dv login
          NoDisplay=true
          Terminal=false
          Exec=${tldvHelper} auth-callback %u
          MimeType=x-scheme-handler/tldv;
        '';
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

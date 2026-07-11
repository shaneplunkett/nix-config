{
  lib,
  pkgs,
  ...
}:
let
  bluebubblesThemed = pkgs.bluebubbles-themed;

  intifaceCentralFixed = pkgs.symlinkJoin {
    name = "intiface-central-fixed";
    paths = [ pkgs.intiface-central ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/intiface_central \
        --prefix LD_LIBRARY_PATH : ${pkgs.intiface-central}/app/intiface-central/lib
    '';
  };

  orcaSlicerFixed = pkgs.symlinkJoin {
    name = "orca-slicer-fixed";
    paths = [ pkgs.orca-slicer-bambulab ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/orca-slicer \
        --set GDK_BACKEND x11 \
        --set GDK_SCALE 1
    '';
  };

  bugRecord = pkgs.writeShellApplication {
    name = "bug-record";
    runtimeInputs = with pkgs; [
      coreutils
      libnotify
      slurp
      wf-recorder
      wl-clipboard
    ];
    text = ''
      set -euo pipefail

      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/bug-record"
      out_dir="$HOME/Videos/Screen Recordings"
      pid_file="$state_dir/pid"
      recording_file="$state_dir/file"

      stop_recording() {
        local pid file
        pid="$(cat "$pid_file" 2>/dev/null || true)"
        file="$(cat "$recording_file" 2>/dev/null || true)"

        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
          kill -INT "$pid" 2>/dev/null || true
          for _ in $(seq 1 50); do
            kill -0 "$pid" 2>/dev/null || break
            sleep 0.1
          done
        fi

        rm -f "$pid_file" "$recording_file"

        if [[ -n "$file" ]]; then
          printf '%s' "$file" | wl-copy
          notify-send "Recording saved" "$file copied to clipboard"
        else
          notify-send "Recording stopped"
        fi
      }

      if [[ -f "$pid_file" ]]; then
        pid="$(cat "$pid_file" 2>/dev/null || true)"
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
          stop_recording
          exit 0
        fi
        rm -f "$pid_file" "$recording_file"
      fi

      mode="''${1:-region}"
      mkdir -p "$state_dir" "$out_dir"
      file="$out_dir/bug-$(date +%Y%m%d-%H%M%S).mp4"
      args=(-f "$file")

      case "$mode" in
        region)
          geometry="$(slurp -d || true)"
          [[ -n "$geometry" ]] || exit 0
          args=(-g "$geometry" "''${args[@]}")
          ;;
        full)
          ;;
        stop)
          notify-send "No recording running"
          exit 0
          ;;
        *)
          printf 'usage: bug-record [region|full|stop]\n' >&2
          exit 2
          ;;
      esac

      wf-recorder "''${args[@]}" > "$state_dir/wf-recorder.log" 2>&1 &
      pid="$!"
      printf '%s' "$pid" > "$pid_file"
      printf '%s' "$file" > "$recording_file"
      notify-send "Recording started" "Run bug-record again to stop"
    '';
  };

  electronFlags = ''
    --ozone-platform-hint=auto
    --enable-features=WaylandWindowDecorations
    --force-device-scale-factor=1.5
  '';
  chromeFlags = ''
    --ozone-platform-hint=auto
    --enable-features=WaylandWindowDecorations
    --password-store=basic
  '';
in
{
  home.activation.bluebubblesThemePrefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    prefs="$HOME/.local/share/app.bluebubbles.BlueBubbles/shared_preferences.json"
    mkdir -p "$(dirname "$prefs")"

    if [[ -f "$prefs" ]]; then
      tmp="$(${pkgs.coreutils}/bin/mktemp)"
      ${pkgs.jq}/bin/jq \
        --arg selected "Shane Desktop" \
        --arg adaptive '{"theme_mode":1,"default_theme_mode":1}' \
        'del(."flutter.closeToTray", ."flutter.minimizeToTray") + {
          "flutter.selected-dark": $selected,
          "flutter.selected-light": $selected,
          "flutter.adaptive_theme_preferences": $adaptive
        }' "$prefs" > "$tmp"
      ${pkgs.coreutils}/bin/mv "$tmp" "$prefs"
    else
      ${pkgs.coreutils}/bin/cat > "$prefs" <<'JSON'
    {
      "flutter.selected-dark": "Shane Desktop",
      "flutter.selected-light": "Shane Desktop",
      "flutter.adaptive_theme_preferences": "{\"theme_mode\":1,\"default_theme_mode\":1}"
    }
    JSON
    fi
  '';

  xdg.configFile = {
    "electron-flags.conf".text = electronFlags;
    "electron32-flags.conf".text = electronFlags;
    "electron33-flags.conf".text = electronFlags;
    "electron34-flags.conf".text = electronFlags;
    "chrome-flags.conf".text = chromeFlags;
  };

  home.packages = with pkgs; [
    zip
    xz
    unzip
    p7zip
    signal-desktop
    bluebubblesThemed
    # Temporarily disabled: upstream Snapcraft fetch is timing out during rebuilds.
    # plex-desktop
    ferdium
    mangohud
    protonup-ng
    shadps4-cache-fixed
    ytmdesktop-bin
    libnotify
    pavucontrol
    blueman
    hyprshot
    grim
    imagemagick
    jq
    swappy
    tesseract
    wf-recorder
    wl-clipboard
    xdg-utils
    cliphist
    bugRecord
    obsidian
    orcaSlicerFixed
    mpv
    vlc
    samrewritten
    bun
    bruno
    kubectl
    intifaceCentralFixed
    megacmd
    yt-dlp
    google-chrome
    slack
    qalculate-qt
  ];
}

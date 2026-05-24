{
  config,
  lib,
  pkgs,
  ...
}:
let
  waydroid = pkgs.waydroid-nftables;
  waydroidBin = lib.getExe waydroid;

  arknights = pkgs.writeShellApplication {
    name = "arknights";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.systemd
      waydroid
    ];
    text = ''
      set -euo pipefail

      is_running() {
        waydroid status 2>/dev/null | grep -q '^Session:[[:space:]]*RUNNING'
      }

      systemctl --user start waydroid-session.service

      for _ in $(seq 1 60); do
        if is_running; then
          break
        fi
        sleep 1
      done

      if ! is_running; then
        echo "Waydroid session did not start." >&2
        waydroid status >&2 || true
        exit 1
      fi

      if [ ! -e /var/lib/waydroid/overlay/system/lib64/libhoudini.so ] \
        && [ ! -e /var/lib/waydroid/overlay/system/lib64/libndk_translation.so ]; then
        echo "Warning: Waydroid ARM translation overlay was not found; Arknights may not launch." >&2
      fi

      waydroid prop set persist.waydroid.width 2456
      waydroid prop set persist.waydroid.height 1290

      exec waydroid app launch com.YoStarEN.Arknights
    '';
  };
in
{
  home = {
    packages = [
      arknights
    ];

    file.".local/share/applications/arknights.desktop" = {
      force = true;
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Arknights
        Exec=${lib.getExe arknights}
        Icon=${config.home.homeDirectory}/.local/share/waydroid/data/icons/com.YoStarEN.Arknights.png
        Categories=Game;X-WayDroid-App;
        X-Purism-FormFactor=Workstation;Mobile;
        Actions=app-settings;

        [Desktop Action app-settings]
        Name=App Settings
        Exec=${waydroidBin} app intent android.settings.APPLICATION_DETAILS_SETTINGS package:com.YoStarEN.Arknights
        Icon=${config.home.homeDirectory}/.local/share/waydroid/data/icons/com.android.settings.png
      '';
    };

    file.".local/share/applications/waydroid.com.YoStarEN.Arknights.desktop" = {
      force = true;
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Arknights
        NoDisplay=true
        Exec=${waydroidBin} app launch com.YoStarEN.Arknights
        Icon=${config.home.homeDirectory}/.local/share/waydroid/data/icons/com.YoStarEN.Arknights.png
        Categories=Game;X-WayDroid-App;
        X-Purism-FormFactor=Workstation;Mobile;
        Actions=app-settings;

        [Desktop Action app-settings]
        Name=App Settings
        Exec=${waydroidBin} app intent android.settings.APPLICATION_DETAILS_SETTINGS package:com.YoStarEN.Arknights
        Icon=${config.home.homeDirectory}/.local/share/waydroid/data/icons/com.android.settings.png
      '';
    };
  };

  systemd.user.services.waydroid-session = {
    Unit = {
      Description = "Waydroid user session";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${waydroidBin} session start";
      ExecStop = "${waydroidBin} session stop";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}

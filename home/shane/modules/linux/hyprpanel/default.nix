{
  lib,
  ...
}:
let
  colours = import ../../common/theme/colours.nix;
  themeConfig = import ./catppuccin_mocha.nix { inherit colours; };
in
{
  # Shell-specific services launched via compositor exec-once
  wayland.windowManager.hyprland.settings.exec-once = [ "swaync" ];

  programs.hyprpanel = {
    enable = true;
    systemd.enable = true;
    settings = {
      theme = lib.recursiveUpdate {

        bar.transparent = true;

        font = {
          name = "Mononoki Nerd Font";
          size = "20px";
        };
      } themeConfig.theme;

      bar.layouts = {
        "DP-2" = {
          left = [
            "cpu"
            "ram"
            "cava"
          ];
          middle = [
            "workspaces"
            "windowtitle"
          ];
          right = [
            "custom/wallpaper"
            "systray"
            "volume"
            "network"
            "bluetooth"
            "clock"
            "notifications"
            "dashboard"
          ];
        };
        "HDMI-A-1" = {
          left = [];
          middle = [];
          right = [];
        };

      };

      bar.launcher.autoDetectIcon = true;
      bar.workspaces.show_icons = true;

      menus.clock = {
        time = {
          military = false;
          hideSeconds = true;
        };
        weather.unit = "metric";
      };

      menus.dashboard.directories.enabled = false;

    };
  };
}

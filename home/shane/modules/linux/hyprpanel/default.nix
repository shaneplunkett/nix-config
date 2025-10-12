{
  lib,
  ...
}:
let
  nordVivid = import ./nord_vivid.nix;
in
{
  programs.hyprpanel = {
    enable = true;
    systemd.enable = true;
    settings = {
      theme = lib.recursiveUpdate {

        bar.transparent = true;

        font = {
          name = "Mononoki Nerd Font";
          size = "16px";
        };
      } nordVivid.theme;

      bar.layouts = {
        "*" = {
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
            "systray"
            "volume"
            "network"
            "bluetooth"
            "clock"
            "notifications"
            "dashboard"
          ];
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
      menus.dashboard.stats.enable_gpu = true;

    };
  };
}

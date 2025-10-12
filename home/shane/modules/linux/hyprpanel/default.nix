{ inputs, ... }:
{
  programs.hyprpanel = {
    enable = true;
    systemd.enable = true;
    settings = {
      theme = {
        name = "nord-vivid";

        bar.transparent = true;

        font = {
          name = "Mononoki Nerd Font";
          size = "16px";
        };
      };

      layout = {
        bar.layouts = {
          "0" = {
            left = [
              "media"
            ];
            middle = [ "workspaces" ];
            right = [
              "volume"
              "systray"
              "notifications"
              "dashboard"
            ];
          };
        };
      };

      bar.launcher.autoDetectIcon = true;
      bar.workspaces.show_icons = true;

      menus.clock = {
        time = {
          military = true;
          hideSeconds = true;
        };
        weather.unit = "metric";
      };

      menus.dashboard.directories.enabled = false;
      menus.dashboard.stats.enable_gpu = true;

    };
  };
}

{ ... }:
{
  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      cssPriority = "user";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-margin-left = 0;
      control-center-width = 400;
      control-center-height = 850;
      notification-window-width = 380;
      notification-icon-size = 50;
      notification-body-image-height = 200;
      notification-body-image-width = 200;
      timeout = 8;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = false;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      text-empty = "No Notifications";
      script-fail-notify = true;

      widgets = [
        "buttons-grid"
        "menubar"
        "volume"
        "dnd"
        "title"
        "notifications"
        "mpris"
      ];

      widget-config = {
        title = {
          text = "Notification Center";
          clear-all-button = true;
          button-text = " 󰆴 ";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        mpris = {
          image-radius = 0;
          autohide = true;
        };
        volume = {
          label = "   ";
          expand-button-label = " ";
          collapse-button-label = " ";
          show-per-app = true;
          show-per-app-icon = true;
          show-per-app-label = false;

        };
        menubar = {
          "buttons#power" = {
            label = "⏻";
            position = "right";
            actions = [
              {
                label = "Shut down";
                command = "systemctl poweroff";
              }
            ];
          };
          "buttons#screenshot" = {
            position = "right";
            actions = [
              {
                label = "󰹑";
                command = "grim";
              }
            ];
          };
          "buttons#bluetooth" = {
            position = "right";
            actions = [
              {
                label = "󰂯";
                command = "blueman-manager";
              }
            ];
          };
        };
        buttons-grid = {
          actions = [
            {
              label = " ";
              type = "toggle";
              active = true;
              command = "";
              update-command = "";
            }
            {
              label = "󰂯";
              type = "toggle";
              active = true;
              command = "";
              update-command = "";
            }
            {
              label = "";
              type = "toggle";
              active = false;
              command = "";
              update-command = "";
            }
            {
              label = "";
              type = "toggle";
              active = false;
              command = "";
              update-command = "";
            }
          ];
        };
      };
    };

    style = ''
      @define-color background rgb(46, 52, 64);
      @define-color background-alt rgb(59, 66, 82);
      @define-color foreground #eceff4;
      @define-color red #bf616a;
      @define-color green #a3be8c;
      @define-color yellow #ebcb8b;
      @define-color blue #88c0d0;
      @define-color gray #4c566a;
      @define-color select #5e81ac;

      * {
        outline: none;
        font-family: "Mononoki Nerd Font";
        font-size: 18px;
        text-shadow: none;
        color: @foreground;
        background-color: transparent;
        border-radius: 2px;
      }

      .control-center {
        background-color: alpha(@background, 1);
        padding: 2px;
        border-bottom: 9px solid @blue;
      }

      .notification-row .notification-background {
        border-radius: 2px;
        margin: 5px 0 15px;
      }

      .notification {
        background-color: @background;
        border: 1px solid alpha(@foreground, 0.05);
        border-radius: 2px;
        padding: 6px 10px;
        margin-bottom: 6px;
        min-height: 50px;
        box-shadow: none;
      }

      .notification .summary {
        font-size: 1rem;
        font-weight: 500;
        margin-bottom: 2px;
      }

      .notification .time {
        font-size: 0.75rem;
        color: alpha(@foreground, 0.6);
      }

      .notification .body {
        font-size: 0.95rem;
        color: @foreground;
      }

      .notification-action > button {
        padding: 5px 10px;
        font-size: 0.9rem;
        background-color: @select;
        color: @foreground;
        border-radius: 2px;
        border: none;
        margin: 6px 6px 0 0;
      }

      .notification-action > button:hover {
        background-color: @blue;
      }

      .notification-action > button:hover label {
        background-color: @blue;
        color: @background;
      }

      .notification.critical {
        background: @red;
        border-left: 9px solid @red;
      }

      .notification.critical .title,
      .notification.critical .body,
      .notification.critical .summary {
        color: alpha(@background, 0.9);
        font-weight: bold;
      }

      .notification.low,
      .notification.normal {
        background-color: alpha(@background, 0.95);
        border-left: 9px solid @blue;
      }

      .image {
        margin-right: 10px;
        min-width: 36px;
        min-height: 36px;
        border: none;
      }

      .close-button {
        background-color: alpha(@gray, 0.8);
        border-radius: 8px;
      }

      .close-button label {
        color: aliceblue;
      }

      .close-button:hover {
        background-color: alpha(@red, 0.8);
      }

      .notification-group-collapse-button,
      .notification-group-close-all-button {
        background-color: @gray;
        color: @foreground;
        border-radius: 6px;
      }

      .notification-group-collapse-button:hover {
        background-color: @blue;
        color: @background;
      }

      .notification-group-close-all-button:hover {
        background-color: @red;
        color: @background;
      }

      scale trough {
        margin: 0 1rem;
        background-color: @gray;
        min-height: 8px;
        min-width: 70px;
        border-radius: 30px;
      }

      trough highlight {
        background: @blue;
        border-radius: 30px;
      }

      slider {
        border-radius: 30px;
        background-color: @foreground;
      }

      tooltip {
        background-color: @gray;
        color: @foreground;
      }

      .widget-buttons-grid {
        font-size: 1rem;
        padding: 20px 20px 10px;
      }

      .widget-buttons-grid button {
        background: @gray;
        color: @foreground;
        border-radius: 50px;
        min-width: 60px;
        min-height: 30px;
        margin: 0 3px;
        padding: 6px;
      }

      .widget-buttons-grid button:hover {
        background: @select;
      }

      .widget-buttons-grid button.toggle:checked {
        background: @blue;
      }

      .widget-buttons-grid button.toggle:checked label {
        background: @blue;
        color: @background;
      }

      .widget-buttons-grid button.toggle:checked:hover {
        background: alpha(@blue, 0.8);
      }

      .widget-mpris .widget-mpris-player {
        padding: 6px;
        margin: 6px 10px;
        background-color: transparent;
        box-shadow: none;
        border-radius: 2px;
      }

      .widget-mpris label,
      .widget-mpris-title,
      .widget-mpris-subtitle {
        color: @foreground;
      }

      .widget-mpris-title {
        font-size: 1.2rem;
        font-weight: bold;
        margin: 0 8px 8px;
        text-align: center;
      }

      .widget-mpris-subtitle {
        font-size: 1rem;
        text-align: center;
      }

      .widget-mpris-album-art.art {
        border-radius: 999px;
        min-width: 128px;
        min-height: 128px;
        background-size: cover;
        background-repeat: no-repeat;
        overflow: hidden;
        box-shadow: none;
      }

      picture.mpris-background {
        opacity: 0;
        background: none;
        box-shadow: none;
        border: none;
      }

      .widget-volume {
        padding: 6px 5px 5px;
        font-size: 1.3rem;
      }

      .widget-volume button {
        border: none;
      }

      .per-app-volume {
        padding: 4px 8px 8px;
        margin: 0 8px 8px;
      }

      .widget-backlight {
        padding: 0 0 3px 16px;
        font-size: 1.1rem;
      }

      .widget-dnd {
        font-weight: bold;
        padding: 20px 15px 15px;
      }

      .widget-dnd > switch {
        background: @yellow;
        border: none;
        border-radius: 100px;
        padding: 3px;
      }

      .widget-dnd > switch:checked {
        background: @green;
      }

      .widget-dnd > switch slider {
        background: @background;
        border-radius: 12px;
        min-width: 12px;
        min-height: 12px;
      }

      .widget-title {
        padding: 15px;
        font-weight: bold;
      }

      .widget-title > label {
        font-size: 1.5rem;
      }

      .widget-title > button {
        background: @red;
        border: none;
        border-radius: 100px;
        padding: 0 6px;
        transition: all 0.7s ease;
      }

      .widget-title > button label {
        color: @background;
      }

      .widget-title > button:hover {
        background: alpha(@red, 0.8);
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.65);
      }

      .blank-window {
        background: transparent;
      }

      .control-center-list {
        background: transparent;
      }
    '';
  };
}

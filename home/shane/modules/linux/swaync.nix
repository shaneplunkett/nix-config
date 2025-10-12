{ ... }:
{
  services.swaync = {
    enable = true;
    
    settings = {
      positionX = "center";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 0;
      control-center-margin-bottom = 0;
      control-center-margin-right = 0;
      control-center-margin-left = 0;
      notification-2fa-action = true;
      notification-inline-replies = false;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = true;
      control-center-width = 500;
      control-center-height = 600;
      notification-window-width = 500;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
      scripts = {
        example-script = {
          exec = "echo 'Do something...'";
          urgency = "Normal";
        };
      };
      notification-visibility = {
        example-name = {
          state = "muted";
          urgency = "Low";
          app-name = "Spotify";
        };
      };
    };

    style = ''
      .floating-notifications.background .notification-row .notification-background {
        box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.8), inset 0 1px 0 0 rgba(255, 255, 255, 0.05);
        border-radius: 12.6px;
        margin: 18px;
        background-color: rgba(61, 56, 70, 0.7);
        color: #cad3f5;
        padding: 0;
      }

      .floating-notifications.background .notification-row .notification-background .notification {
        padding: 7px;
        border-radius: 12.6px;
      }

      .floating-notifications.background .notification-row .notification-background .notification.critical {
        box-shadow: inset 0 0 7px 0 #ed8796;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content {
        margin: 7px;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
        color: #cad3f5;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
        color: #a5adcb;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
        color: #cad3f5;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
        min-height: 3.4em;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
        border-radius: 7px;
        color: #cad3f5;
        background-color: #494d64;
        box-shadow: inset 0 0 0 1px #6e738d;
        margin: 7px;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
        box-shadow: inset 0 0 0 1px #6e738d;
        background-color: #5b6078;
        color: #cad3f5;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
        box-shadow: inset 0 0 0 1px #6e738d;
        background-color: #494d64;
        color: #cad3f5;
      }

      .control-center {
        box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 1px 0 0 rgba(255, 255, 255, 0.05);
        border-radius: 12.6px;
        margin: 18px;
        background-color: rgba(61, 56, 70, 0.7);
        color: #cad3f5;
        padding: 14px;
      }

      .control-center .widget-title > label {
        color: #cad3f5;
        font-size: 1.3em;
      }

      .control-center .widget-title button {
        border-radius: 7px;
        color: #cad3f5;
        background-color: #494d64;
        box-shadow: inset 0 0 0 1px #6e738d;
      }

      .control-center .widget-title button:hover {
        box-shadow: inset 0 0 0 1px #6e738d;
        background-color: #5b6078;
        color: #cad3f5;
      }

      .control-center .widget-title button:active {
        box-shadow: inset 0 0 0 1px #6e738d;
        background-color: #494d64;
        color: #cad3f5;
      }
    '';
  };
}

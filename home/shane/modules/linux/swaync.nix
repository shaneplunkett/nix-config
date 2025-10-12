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
        border-radius: 8px;
        margin: 18px;
        background-color: rgba(59, 66, 82, 0.95);  /* Nord Polar Night */
        color: #d8dee9;  /* Nord Snow Storm */
        padding: 0;
        border: 2px solid #5e81ac;  /* Nord Frost */
      }

      .floating-notifications.background .notification-row .notification-background .notification {
        padding: 10px;
        border-radius: 8px;
      }

      .floating-notifications.background .notification-row .notification-background .notification.critical {
        box-shadow: inset 0 0 7px 0 #bf616a;  /* Nord Aurora red */
        border-color: #bf616a;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content {
        margin: 7px;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
        color: #eceff4;  /* Nord Snow Storm bright */
        font-weight: bold;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
        color: #81a1c1;  /* Nord Frost light */
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
        color: #d8dee9;  /* Nord Snow Storm */
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
        min-height: 3.4em;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
        border-radius: 6px;
        color: #eceff4;  /* Nord Snow Storm bright */
        background-color: #434c5e;  /* Nord Polar Night lighter */
        border: 2px solid #5e81ac;  /* Nord Frost */
        margin: 7px;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
        background-color: #5e81ac;  /* Nord Frost */
        color: #eceff4;
        border-color: #88c0d0;  /* Nord Frost lighter */
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
        background-color: #434c5e;
        color: #eceff4;
        border-color: #5e81ac;
      }

      .control-center {
        box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 1px 0 0 rgba(255, 255, 255, 0.05);
        border-radius: 8px;
        margin: 18px;
        background-color: rgba(59, 66, 82, 0.95);  /* Nord Polar Night */
        color: #d8dee9;  /* Nord Snow Storm */
        padding: 14px;
        border: 2px solid #5e81ac;  /* Nord Frost */
      }

      .control-center .widget-title > label {
        color: #eceff4;  /* Nord Snow Storm bright */
        font-size: 1.3em;
        font-weight: bold;
      }

      .control-center .widget-title button {
        border-radius: 6px;
        color: #eceff4;  /* Nord Snow Storm bright */
        background-color: #434c5e;  /* Nord Polar Night lighter */
        border: 2px solid #5e81ac;  /* Nord Frost */
      }

      .control-center .widget-title button:hover {
        background-color: #5e81ac;  /* Nord Frost */
        color: #eceff4;
        border-color: #88c0d0;  /* Nord Frost lighter */
      }

      .control-center .widget-title button:active {
        background-color: #434c5e;
        color: #eceff4;
        border-color: #5e81ac;
      }

      .control-center .notification-row .notification-background {
        background-color: rgba(67, 76, 94, 0.8);  /* Nord Polar Night even lighter */
        border: 1px solid #5e81ac;
        border-radius: 6px;
        margin: 4px 0;
      }

      .control-center .notification-row .notification-background .notification {
        color: #d8dee9;
        padding: 8px;
      }

      .control-center .notification-row .notification-background .notification .notification-content .summary {
        color: #eceff4;
        font-weight: bold;
      }
    '';
  };
}

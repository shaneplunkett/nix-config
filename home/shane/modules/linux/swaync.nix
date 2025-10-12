{ ... }:
{
  services.swaync = {
    enable = true;
    
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
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
      control-center-width = 380;
      control-center-height = 700;
      notification-window-width = 380;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;

      widgets = [
        "inhibitors"
        "title"
        "dnd"
        "notifications"
        "mpris"
        "volume"
        "wifi"
        "bluetooth"
      ];

      widget-config = {
        inhibitors = {
          text = "Inhibitors";
          button-text = "Clear All";
          clear-all-button = true;
        };
        title = {
          text = "Notification Center";
          clear-all-button = true;
          button-text = "Clear All";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        volume = {
          label = "Volume";
          show-per-app = true;
        };
        wifi = {
          label = "Wi-Fi";
        };
        bluetooth = {
          label = "Bluetooth";
        };
        mpris = {
          image-size = 96;
          image-radius = 8;
        };
      };

      scripts = {
        volume-up = {
          exec = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          urgency = "Low";
        };
        volume-down = {
          exec = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          urgency = "Low";
        };
        volume-mute = {
          exec = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          urgency = "Low";
        };
      };
    };

    style = ''
      /* Main control center styling - macOS inspired */
      .control-center {
        background: rgba(46, 52, 64, 0.98);  /* Nord Polar Night darkest with transparency */
        border-radius: 16px;
        margin: 0;
        padding: 0;
        border: 1px solid rgba(136, 192, 208, 0.3);  /* Nord Frost with transparency */
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
        backdrop-filter: blur(20px);
      }

      /* Control center header */
      .control-center .widget-title {
        background: transparent;
        padding: 16px 20px 8px 20px;
        border-bottom: 1px solid rgba(136, 192, 208, 0.2);
        margin-bottom: 12px;
      }

      .control-center .widget-title > label {
        color: #eceff4;  /* Nord Snow Storm bright */
        font-size: 18px;
        font-weight: 600;
        margin: 0;
      }

      .control-center .widget-title button {
        background: rgba(94, 129, 172, 0.2);  /* Nord Frost with transparency */
        border: 1px solid rgba(136, 192, 208, 0.4);
        border-radius: 12px;
        color: #88c0d0;  /* Nord Frost */
        padding: 6px 12px;
        font-size: 13px;
        font-weight: 500;
        transition: all 0.2s ease;
      }

      .control-center .widget-title button:hover {
        background: rgba(136, 192, 208, 0.3);
        border-color: #88c0d0;
        color: #eceff4;
      }

      /* Widget sections */
      .widget-dnd, .widget-inhibitors {
        background: rgba(67, 76, 94, 0.6);  /* Nord Polar Night lighter */
        border-radius: 12px;
        margin: 8px 16px;
        padding: 12px 16px;
        border: 1px solid rgba(136, 192, 208, 0.2);
      }

      .widget-dnd > switch, .widget-inhibitors > switch {
        border-radius: 16px;
        background: rgba(94, 129, 172, 0.3);
        border: 1px solid rgba(136, 192, 208, 0.4);
      }

      .widget-dnd > switch:checked, .widget-inhibitors > switch:checked {
        background: #88c0d0;  /* Nord Frost */
      }

      /* Control widgets (Volume, WiFi, Bluetooth) */
      .widget-volume, .widget-wifi, .widget-bluetooth {
        background: rgba(67, 76, 94, 0.6);
        border-radius: 12px;
        margin: 8px 16px;
        padding: 16px;
        border: 1px solid rgba(136, 192, 208, 0.2);
      }

      .widget-volume .widget-label, .widget-wifi .widget-label, .widget-bluetooth .widget-label {
        color: #eceff4;
        font-size: 15px;
        font-weight: 500;
        margin-bottom: 8px;
      }

      /* Volume slider */
      .widget-volume scale {
        margin: 8px 0;
      }

      .widget-volume scale trough {
        background: rgba(94, 129, 172, 0.3);
        border-radius: 8px;
        min-height: 6px;
        border: none;
      }

      .widget-volume scale highlight {
        background: linear-gradient(90deg, #88c0d0, #81a1c1);  /* Nord Frost gradient */
        border-radius: 8px;
      }

      .widget-volume scale slider {
        background: #eceff4;  /* Nord Snow Storm bright */
        border: 2px solid #88c0d0;
        border-radius: 50%;
        min-width: 18px;
        min-height: 18px;
      }

      /* WiFi and Bluetooth toggle buttons */
      .widget-wifi button, .widget-bluetooth button {
        background: rgba(94, 129, 172, 0.3);
        border: 1px solid rgba(136, 192, 208, 0.4);
        border-radius: 10px;
        color: #d8dee9;
        padding: 8px 16px;
        font-size: 13px;
        transition: all 0.2s ease;
        width: 100%;
      }

      .widget-wifi button:hover, .widget-bluetooth button:hover {
        background: rgba(136, 192, 208, 0.4);
        border-color: #88c0d0;
      }

      .widget-wifi button.active, .widget-bluetooth button.active {
        background: #88c0d0;
        color: #2e3440;  /* Nord Polar Night darkest */
        border-color: #88c0d0;
      }

      /* Media player widget */
      .widget-mpris {
        background: rgba(67, 76, 94, 0.6);
        border-radius: 12px;
        margin: 8px 16px;
        padding: 16px;
        border: 1px solid rgba(136, 192, 208, 0.2);
      }

      .widget-mpris-player {
        padding: 8px;
      }

      .widget-mpris-title {
        color: #eceff4;
        font-size: 15px;
        font-weight: 600;
      }

      .widget-mpris-subtitle {
        color: #81a1c1;  /* Nord Frost light */
        font-size: 13px;
      }

      /* Notifications area */
      .widget-notifications {
        margin: 8px 16px 16px 16px;
      }

      .widget-notifications .notification-row .notification-background {
        background: rgba(67, 76, 94, 0.6);
        border-radius: 12px;
        margin: 6px 0;
        border: 1px solid rgba(136, 192, 208, 0.2);
        padding: 0;
      }

      .widget-notifications .notification-row .notification {
        padding: 12px 16px;
        border-radius: 12px;
        color: #d8dee9;
      }

      .widget-notifications .notification-row .notification .notification-content .summary {
        color: #eceff4;
        font-weight: 600;
        font-size: 14px;
        margin-bottom: 4px;
      }

      .widget-notifications .notification-row .notification .notification-content .body {
        color: #d8dee9;
        font-size: 13px;
        line-height: 1.4;
      }

      .widget-notifications .notification-row .notification .notification-content .time {
        color: #81a1c1;
        font-size: 12px;
      }

      /* Floating notifications styling */
      .floating-notifications.background .notification-row .notification-background {
        background: rgba(46, 52, 64, 0.98);
        border-radius: 12px;
        margin: 8px 16px;
        border: 1px solid rgba(136, 192, 208, 0.3);
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4);
        backdrop-filter: blur(20px);
      }

      .floating-notifications.background .notification-row .notification {
        padding: 12px 16px;
        border-radius: 12px;
        color: #d8dee9;
      }

      .floating-notifications.background .notification-row .notification.critical {
        border-color: #bf616a;  /* Nord Aurora red */
        box-shadow: 0 4px 16px rgba(191, 97, 106, 0.3);
      }

      .floating-notifications.background .notification-row .notification .notification-content .summary {
        color: #eceff4;
        font-weight: 600;
        font-size: 14px;
      }

      .floating-notifications.background .notification-row .notification .notification-content .body {
        color: #d8dee9;
        font-size: 13px;
      }

      .floating-notifications.background .notification-row .notification .notification-content .time {
        color: #81a1c1;
        font-size: 12px;
      }
    '';
  };
}

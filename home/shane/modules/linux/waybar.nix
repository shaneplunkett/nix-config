{ ... }:
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        output = "DP-2";
        spacing = 5;
        layer = "top";
        position = "top";
        height = 30;
        start_hidden = true;
        modules-right = [
          "clock"
          "network"
          "bluetooth"
          "pulseaudio"
          "tray"
        ];
        modules-center = [ ];
        modules-left = [
          "cpu"
          "memory"
          "temperature"
        ];

        tray = {
          icon-size = 14;
          spacing = 10;
        };

        clock = {
          format = "{:%I:%M:%S %p}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%m/%d/%Y}";
          interval = 1;
        };

        cpu = {
          format = "{usage}% ";
          on-click = "foot btop";
        };

        memory = {
          format = "{}%  ";
          on-click = "foot btop";
        };

        temperature = {
          format = "{temperatureC}°C {icon}";
          format-icons = [
            ""
            ""
            "󰈸"
          ];
          tooltip = false;
          on-click = "foot btop";
          "critical-threshold" = 80;
        };

        backlight = {
          format = "{percent}% {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
          tooltip = false;
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon} ";
          format-full = "{capacity}% {icon} ";
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon} ";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip = true;
          "tooltip-format" = "Power profile: {profile}\nDriver: {driver}";
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };

        bluetooth = {
          format = " {status}";
          format-disabled = "";
          format-connected = " {num_connections} connected";
          tooltip-format = "{controller_alias}\t{controller_address}";
          "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
          on-click = "blueman-manager";
        };

        network = {
          format-wifi = "{signalStrength}%  ";
          format-ethernet = "{ifname} 󰈀 ";
          "tooltip-format" = "{essid}";
          format-linked = "{ifname} (No IP)  ";
          format-disconnected = "Disconnected ⚠ ";
        };

        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = "󰝟 {icon} {format_source}";
          format-muted = "󰝟 {format_source}";
          format-source = "{volume}% ";
          format-source-muted = " ";
          format-icons = {
            headphone = " ";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };
      };
    };

    style = ''
      * {
          padding: 2px;
          border-radius: 8px;
          font-size: 16;
          font-family: "Mononoki Nerd Font" ;
          min-height: 20px;
      }

      window#waybar {
          background-color: rgba(0, 0, 0, 0);
          color: #cdd6f4;
          border: none;
          box-shadow: none;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      window#waybar.termite {
          background-color: #3F3F3F;
      }

      window#waybar.chromium {
          background-color: #000000;
          border: none;
      }

      #workspaces {
          border: 3px solid #b4befe;
      }

      #workspaces button {
          padding-right: 6px;
          padding-left: 0px;
          padding-top: 0px;
          padding-bottom: 0px;
          background-color: transparent;
          color: #cdd6f4;
      }

      #workspaces button:hover {
          color: #f5c2e7;
      }

      #workspaces button.empty {
          color: #7f849c;
      }

      #workspaces button.active {
          color: #f5c2e7;
      }

      #workspaces button.urgent {
          color: #f38ba8;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #temperature,
      #backlight,
      #network,
      #bluetooth,
      #pulseaudio,
      #tray,
      #workspaces,
      #power-profiles-daemon {
          padding: 0 10px;
          background-color: #1e1e2e;
          color: #cdd6f4;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0px;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #clock {
          border: 3px solid #89dceb;
      }

      #battery {
          border: 3px solid #b4befe;
      }

      #battery.charging, #battery.plugged {
          border: 3px solid #a6e3a1;
      }

      @keyframes blink {
          to {
              border: 3px solid #b4befe;
          }
      }

      /* Using steps() instead of linear as a timing function to limit cpu usage */
      #battery.critical:not(.charging) {
          border: 3px solid #f38ba8;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #power-profiles-daemon {
          padding-right: 18px;
      }

      #power-profiles-daemon.performance {
          border: 3px solid #f38ba8;
      }

      #power-profiles-daemon.balanced {
          border: 3px solid #f5c2e7;
      }

      #power-profiles-daemon.power-saver {
          border: 3px solid #a6e3a1;
      }

      #cpu {
          border: 3px solid #a6e3a1;
          padding-right: 15px
      }

      #memory {
          border: 3px solid #cba6f7
      }

      #backlight {
          border: 3px solid #f9e2af;
      }

      #bluetooth {
          border: 3px solid #89b4fa;
      }

      #network {
          border: 3px solid #89dceb;
      }

      #network.disconnected {
          border: 3px solid #f38ba8;
      }

      #pulseaudio {
          border: 3px solid #cba6f7;
      }

      #pulseaudio.muted {
          border: 3px solid #f38ba8;
      }

      #custom-media {
          border: 3px solid #a6e3a1;
          min-width: 100px;
      }

      #custom-media.custom-spotify {
          border: 3px solid #a6e3a1;
      }

      #custom-media.custom-vlc {
          border: 3px solid #fab387;
      }

      #custom-media.custom-firefox {
          border: 3px solid #f38ba8;
      }

      #temperature {
          border: 3px solid #fab387;
      }

      #temperature.critical {
          border: 3px solid #f38ba8;
      }

      #tray {
          border: 3px solid #fab387;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          border: 3px solid #f38ba8;
      }

      #GtkSeparatorMenuItem {
          border-radius: 0px;
          padding: 0px;
      }
    '';
  };
}

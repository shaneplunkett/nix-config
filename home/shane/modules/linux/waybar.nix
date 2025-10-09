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
          color: #d8dee9;  /* Nord Snow Storm */
          border: none;
          box-shadow: none;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      window#waybar.termite {
          background-color: #3b4252;  /* Nord Polar Night */
      }

      window#waybar.chromium {
          background-color: #2e3440;  /* Nord Polar Night darkest */
          border: none;
      }

      #workspaces {
          border: 3px solid #88c0d0;  /* Nord Frost */
      }

      #workspaces button {
          padding-right: 6px;
          padding-left: 0px;
          padding-top: 0px;
          padding-bottom: 0px;
          background-color: transparent;
          color: #d8dee9;  /* Nord Snow Storm */
      }

      #workspaces button:hover {
          color: #81a1c1;  /* Nord Frost lighter */
      }

      #workspaces button.empty {
          color: #616e88;  /* Nord muted */
      }

      #workspaces button.active {
          color: #88c0d0;  /* Nord Frost */
      }

      #workspaces button.urgent {
          color: #bf616a;  /* Nord Aurora red */
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
          background-color: #3b4252;  /* Nord Polar Night */
          color: #d8dee9;  /* Nord Snow Storm */
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
          border: 3px solid #88c0d0;  /* Nord Frost */
      }

      #battery {
          border: 3px solid #81a1c1;  /* Nord Frost lighter */
      }

      #battery.charging, #battery.plugged {
          border: 3px solid #a3be8c;  /* Nord Aurora green */
      }

      @keyframes blink {
          to {
              border: 3px solid #81a1c1;  /* Nord Frost lighter */
          }
      }

      /* Using steps() instead of linear as a timing function to limit cpu usage */
      #battery.critical:not(.charging) {
          border: 3px solid #bf616a;  /* Nord Aurora red */
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
          border: 3px solid #bf616a;  /* Nord Aurora red */
      }

      #power-profiles-daemon.balanced {
          border: 3px solid #b48ead;  /* Nord Aurora purple */
      }

      #power-profiles-daemon.power-saver {
          border: 3px solid #a3be8c;  /* Nord Aurora green */
      }

      #cpu {
          border: 3px solid #a3be8c;  /* Nord Aurora green */
          padding-right: 15px
      }

      #memory {
          border: 3px solid #b48ead;  /* Nord Aurora purple */
      }

      #backlight {
          border: 3px solid #ebcb8b;  /* Nord Aurora yellow */
      }

      #bluetooth {
          border: 3px solid #5e81ac;  /* Nord Frost darker */
      }

      #network {
          border: 3px solid #88c0d0;  /* Nord Frost */
      }

      #network.disconnected {
          border: 3px solid #bf616a;  /* Nord Aurora red */
      }

      #pulseaudio {
          border: 3px solid #b48ead;  /* Nord Aurora purple */
      }

      #pulseaudio.muted {
          border: 3px solid #bf616a;  /* Nord Aurora red */
      }

      #custom-media {
          border: 3px solid #a3be8c;  /* Nord Aurora green */
          min-width: 100px;
      }

      #custom-media.custom-spotify {
          border: 3px solid #a3be8c;  /* Nord Aurora green */
      }

      #custom-media.custom-vlc {
          border: 3px solid #d08770;  /* Nord Aurora orange */
      }

      #custom-media.custom-firefox {
          border: 3px solid #bf616a;  /* Nord Aurora red */
      }

      #temperature {
          border: 3px solid #d08770;  /* Nord Aurora orange */
      }

      #temperature.critical {
          border: 3px solid #bf616a;  /* Nord Aurora red */
      }

      #tray {
          border: 3px solid #d08770;  /* Nord Aurora orange */
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          border: 3px solid #bf616a;  /* Nord Aurora red */
      }

      #GtkSeparatorMenuItem {
          border-radius: 0px;
          padding: 0px;
      }
    '';
  };
}

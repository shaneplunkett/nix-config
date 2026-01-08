{ ... }:
{
  programs.waybar = {
    enable = false;

    settings = {
      mainBar = {
        output = "DP-2";
        spacing = 5;
        layer = "top";
        position = "top";
        height = 30;
        modules-right = [
          "clock"
          "tray"
          "custom/notification"
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
          format-bluetooth-muted = "󰝟 {icon} {format_source}";
          format-muted = "󰝟 {format_source}";
          format-source = "{volume}% ";
          format-source-muted = " ";
          format-icons = {
            headphone = " ";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          "format-icons" = {
            notification = "󱅫";
            none = " ";
            "dnd-notification" = "  ";
            "dnd-none" = "󰂛";
            "inhibited-notification" = " ";
            "inhibited-none" = "";
            "dnd-inhibited-notification" = "  ";
            "dnd-inhibited-none" = "  ";
          };
          "return-type" = "json";
          "exec-if" = "which swaync-client";
          exec = "swaync-client -swb";
          "on-click" = "sleep 0.1 && swaync-client -t -sw";
          "on-click-right" = "sleep 0.1 && swaync-client -d -sw";
          escape = true;
        };
      };
    };

    style = ''
        * {
            border-radius: 8px;
            font-size: 16;
            font-family: "Mononoki Nerd Font" ;
            min-height: 20px;
        }

        window#waybar {
            background-color: rgba(0, 0, 0, 0);
            color: #cdd6f4;  /* Nord Snow Storm */
            border: none;
            box-shadow: none;
        }

        window#waybar.hidden {
            opacity: 0.2;
        }

        window#waybar.termite {
            background-color: #181825;  /* Nord Polar Night */
        }

        window#waybar.chromium {
            background-color: #11111b;  /* Nord Polar Night darkest */
            border: none;
        }

        #workspaces {
            border: 3px solid #89dceb;  /* Nord Frost */
        }

        #workspaces button {
            padding-right: 6px;
            padding-left: 0px;
            padding-top: 0px;
            padding-bottom: 0px;
            background-color: transparent;
            color: #cdd6f4;  /* Nord Snow Storm */
        }

        #workspaces button:hover {
            color: #89b4fa;  /* Nord Frost lighter */
        }

        #workspaces button.empty {
            color: #6c7086;  /* Nord muted */
        }

        #workspaces button.active {
            color: #89dceb;  /* Nord Frost */
        }

        #workspaces button.urgent {
            color: #f38ba8;  /* Nord Aurora red */
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #temperature,
        #backlight,
        #tray,
        #workspaces,
        #power-profiles-daemon,
        #custom-notification {
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
            border: 3px solid #89dceb;  /* Nord Frost */
        }

        #battery {
            border: 3px solid #89b4fa;  /* Nord Frost lighter */
        }

        #battery.charging, #battery.plugged {
            border: 3px solid #a6e3a1;  /* Nord Aurora green */
        }

        @keyframes blink {
            to {
                border: 3px solid #89b4fa;  /* Nord Frost lighter */
            }
        }

        /* Using steps() instead of linear as a timing function to limit cpu usage */
        #battery.critical:not(.charging) {
            border: 3px solid #f38ba8;  /* Nord Aurora red */
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
            border: 3px solid #f38ba8;  /* Nord Aurora red */
        }

        #power-profiles-daemon.balanced {
            border: 3px solid #cba6f7;  /* Nord Aurora purple */
        }

        #power-profiles-daemon.power-saver {
            border: 3px solid #a6e3a1;  /* Nord Aurora green */
        }

        #cpu {
            border: 3px solid #a6e3a1;  /* Nord Aurora green */
            padding-right: 15px;
        }

        #memory {
            border: 3px solid #cba6f7;  /* Nord Aurora purple */
        }

        #backlight {
            border: 3px solid #f9e2af;  /* Nord Aurora yellow */
        }



        #custom-media {
            border: 3px solid #a6e3a1;  /* Nord Aurora green */
            min-width: 100px;
        }

        #custom-media.custom-spotify {
            border: 3px solid #a6e3a1;  /* Nord Aurora green */
        }

        #custom-media.custom-vlc {
            border: 3px solid #fab387;  /* Nord Aurora orange */
        }

        #custom-media.custom-firefox {
            border: 3px solid #f38ba8;  /* Nord Aurora red */
        }

        #temperature {
            border: 3px solid #fab387;  /* Nord Aurora orange */
        }

        #temperature.critical {
            border: 3px solid #f38ba8;  /* Nord Aurora red */
        }

        #tray {
            border: 3px solid #fab387;  /* Nord Aurora orange */
        }

        #tray > .passive {
            -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
            -gtk-icon-effect: highlight;
            border: 3px solid #f38ba8;  /* Nord Aurora red */
        }

        #custom-notification {
            border: 3px solid #89dceb;  /* Nord Frost */
            font-size: 18px;
            padding-top: 2px;
            padding-bottom: 2px;
            padding-left: 8px;
            padding-right: 8px;
        }

        #custom-notification.notification {
            border: 3px solid #f9e2af;  /* Nord Aurora yellow */
        }

        #custom-notification.dnd-notification {
            border: 3px solid #f38ba8;  /* Nord Aurora red */
        }

        #GtkSeparatorMenuItem {
            border-radius: 0px;
        padding: 0px;
      }
    '';
  };
}

{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "ghostty";

      exec-once = [
        "swaync"
        "systemctl --user start hyprpolkitagent"
        "hyprpanel"
        "hyprpaper"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      bind = [
        "$mod_SHIFT, Q, killactive"
        "$mod, A, exec, claude"
        "$mod, RETURN, exec, $terminal"
        "$mod, space, exec, rofi -show drun"
        "$mod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        "$mod_SHIFT, 4, exec, hyprshot -m region --clipboard-only"
        "$mod_SHIFT,W,exec,hyprctl dispatch togglehidden"

        "$mod,1,workspace,1"
        "$mod,A,workspace,2"
        "$mod,B,workspace,3"
        "$mod,E,workspace,4"
        "$mod,T,workspace,5"
        "$mod,S,workspace,6"
        "$mod,M,workspace,7"
        "$mod,O,workspace,8"
        "$mod,9,workspace,9"
        "$mod,G,workspace,10"

        "$mod_SHIFT,1,movetoworkspace,1"
        "$mod_SHIFT,A,movetoworkspace,2"
        "$mod_SHIFT,B,movetoworkspace,3"
        "$mod_SHIFT,E,movetoworkspace,4"
        "$mod_SHIFT,T,movetoworkspace,5"
        "$mod_SHIFT,S,movetoworkspace,6"
        "$mod_SHIFT,M,movetoworkspace,7"
        "$mod_SHIFT,O,movetoworkspace,8"
        "$mod_SHIFT,9,movetoworkspace,9"
        "$mod_SHIFT,G,movetoworkspace,10"

        "$mod_SHIFT,h,movewindow,l"
        "$mod_SHIFT,l,movewindow,r"
        "$mod_SHIFT,k,movewindow,u"
        "$mod_SHIFT,j,movewindow,d"

        "$mod,h,movefocus,l"
        "$mod,l,movefocus,r"
        "$mod,k,movefocus,u"
        "$mod,j,movefocus,d"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"

      ];

      animations = {
        enabled = true;

        bezier = [
          "easeout, 0.25, 0.1, 0.25, 1"
        ];

        animation = [
          "windows, 1, 3, easeout, gnomed"
          "windowsOut, 1, 3, easeout, gnomed"
          "fade, 1, 3, easeout"
          "border, 1, 10, easeout"
          "workspaces, 1, 2, easeout, slide"
        ];
      };

      windowrulev2 = [
        "float, class:(com.example.launcher)"
        "size 500 430, class:(com.example.launcher)"
        #Plex
        "opaque, title:Plex*"
        #Thunar
        "float, title:.*Thunar"
        "size 1100 700, title:.*Thunar"
        #Bluetooth
        "float, title:.*Bluetooth Devices"
        "size 1100 700, title:.*Bluetooth Devices"
        #Volume Control
        "float, title:.*Volume Control"
        "size 1100 700, title:.*Volume Control"
      ];

      monitor = [
        "DP-2,3840x2160@240,0x0,1,vrr, 2"
        "HDMI-A-1, 2560x1440@60, -1440x0, 1, transform, 3"
      ];

      workspace = [
        "1, monitor:DP-2"
        "2, monitor:DP-2"
        "3, monitor:DP-2"
        "4, monitor:DP-2"
        "5, monitor:DP-2"
        "6, monitor:DP-2"
        "7, monitor:DP-2"
        "8, monitor:DP-2"
        "10, monitor:DP-2"
        "9, monitor:HDMI-A-1, default:true"
      ];

      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 8;
          passes = 1;
          new_optimizations = true;
        };

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1e1e2eff)"; # Base
          color_inactive = "rgba(181825ff)"; # Mantle
        };
      };

      general = {
        border_size = 2;
        gaps_in = 5;
        gaps_out = 25;
        resize_on_border = true;

        "col.active_border" = "rgba(89b4faff) rgba(89dcebff) 45deg";
        "col.inactive_border" = "rgba(585b70ff)";
      };

      group = {
        "col.border_active" = "rgba(a6e3a1ff)";
        "col.border_inactive" = "rgba(585b70ff)";
        groupbar = {
          font_size = 10;
          gradients = false;
          "col.active" = "rgba(89b4faff)";
          "col.inactive" = "rgba(313244ff)";
        };
      };
    };
  };
}

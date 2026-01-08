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
        "hyprpaper"
        "hyprpanel"
      ];

      bind = [
        "$mod_SHIFT, Q, killactive"
        "$mod, A, exec, claude"
        "$mod, RETURN, exec, $terminal"
        "$mod, space, exec, rofi -show drun"
        "$mod_SHIFT, 4, exec, hyprshot -m region --clipboard-only"
        "$mod_SHIFT,W,exec,hyprctl dispatch togglehidden"

        # Semantic Workspace Access
        "$mod,1,workspace,1" # Default 1
        "$mod,B,workspace,3" # B for Browser
        "$mod,E,workspace,4" # E for Email or Editor
        "$mod,T,workspace,5" # T for Terminal
        "$mod,S,workspace,6" # S for Slack or Social
        "$mod,M,workspace,7" # M for Music or Meetings
        "$mod,O,workspace,8" # O for Obsidian or Organisation
        "$mod,G,workspace,10" # G for Games

        # Move Focused Window to Mapped Workspace
        "$mod_SHIFT,1,movetoworkspace,1"
        "$mod_SHIFT,A,movetoworkspace,2"
        "$mod_SHIFT,B,movetoworkspace,3"
        "$mod_SHIFT,E,movetoworkspace,4"
        "$mod_SHIFT,T,movetoworkspace,5"
        "$mod_SHIFT,S,movetoworkspace,6"
        "$mod_SHIFT,M,movetoworkspace,7"
        "$mod_SHIFT,O,movetoworkspace,8"
        "$mod_SHIFT,G,movetoworkspace,10"

        # Move Window
        "$mod_SHIFT,h,movewindow,l"
        "$mod_SHIFT,l,movewindow,r"
        "$mod_SHIFT,k,movewindow,u"
        "$mod_SHIFT,j,movewindow,d"

        # Change Focus Window
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
        # Center primary monitor
        "DP-2,3840x2160@240,0x0,1,vrr, 2"

      ];
      decoration = {
        rounding = 10;

        # Catppuccin Mocha settings
        blur = {
          enabled = true;
          size = 8;
          passes = 1;
          new_optimizations = true;
        };

        # Catppuccin Mocha shadows
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

        # Catppuccin Mocha border colors
        "col.active_border" = "rgba(89b4faff) rgba(89dcebff) 45deg"; # Blue to Sky gradient
        "col.inactive_border" = "rgba(585b70ff)"; # Surface2
      };

      # Catppuccin Mocha group settings
      group = {
        "col.border_active" = "rgba(a6e3a1ff)"; # Green
        "col.border_inactive" = "rgba(585b70ff)"; # Surface2
        groupbar = {
          font_size = 10;
          gradients = false;
          "col.active" = "rgba(89b4faff)"; # Blue
          "col.inactive" = "rgba(313244ff)"; # Surface0
        };
      };
    };
  };
}

{ lib, ... }:
{
  # Wayland environment variables

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Nord colorscheme
      "$nord0" = "rgb(2e3440)";   # Polar Night - darkest
      "$nord1" = "rgb(3b4252)";   # Polar Night
      "$nord2" = "rgb(434c5e)";   # Polar Night
      "$nord3" = "rgb(4c566a)";   # Polar Night - lightest
      "$nord4" = "rgb(d8dee9)";   # Snow Storm - darkest
      "$nord5" = "rgb(e5e9f0)";   # Snow Storm
      "$nord6" = "rgb(eceff4)";   # Snow Storm - lightest
      "$nord7" = "rgb(8fbcbb)";   # Frost - teal
      "$nord8" = "rgb(88c0d0)";   # Frost - light blue
      "$nord9" = "rgb(81a1c1)";   # Frost - blue
      "$nord10" = "rgb(5e81ac)";  # Frost - dark blue
      "$nord11" = "rgb(bf616a)";  # Aurora - red
      "$nord12" = "rgb(d08770)";  # Aurora - orange
      "$nord13" = "rgb(ebcb8b)";  # Aurora - yellow
      "$nord14" = "rgb(a3be8c)";  # Aurora - green
      "$nord15" = "rgb(b48ead)";  # Aurora - purple
      "$mod" = "SUPER";
      "$terminal" = "ghostty --gtk-single-instance=true";

      exec-once = [
        "dunst"
        "systemctl --user start hyprpolkitagent"
        "hyprpaper"

      ];

      bind = [
        "$mod_SHIFT, Q, killactive"
        "$mod_SHIFT, RETURN, exec, $terminal"
        "$mod, space, exec, rofi -show drun"
        "$mod_SHIFT, 4, exec, hyprshot -m region --clipboard-only"
        "$mod_SHIFT,W,exec,hyprctl dispatch togglehidden"
        "$mod_SHIFT,Z,exec,killall .waybar-wrapped || waybar"

        # Semantic Workspace Access
        "$mod,1,workspace,1" # Default 1
        "$mod,A,workspace,2" # A for AI
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
        
        # Nord-themed shadows
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "$nord0";
        "col.shadow_inactive" = "$nord1";
        
        # Blur settings with Nord feel
        blur = {
          enabled = true;
          size = 8;
          passes = 1;
          new_optimizations = true;
        };
      };
      
      general = {
        border_size = 2;
        gaps_in = 5;
        gaps_out = 10;
        
        # Nord border colors
        "col.active_border" = "$nord8 $nord9 45deg";  # Frost gradient
        "col.inactive_border" = "$nord3";             # Polar Night
        
        # Background color
        "col.background" = "$nord0";
      };
      
      # Nord-themed group settings
      group = {
        "col.border_active" = "$nord14";    # Aurora green
        "col.border_inactive" = "$nord3";   # Polar Night
        groupbar = {
          font_size = 10;
          gradients = false;
          "col.active" = "$nord8";          # Frost blue
          "col.inactive" = "$nord2";        # Polar Night
        };
      };
    };
  };
}

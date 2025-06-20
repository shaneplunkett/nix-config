{ ... }:
{
  home.sessionVariables.NIXOS_OZONE_WL = "1";
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "ghostty --gtk-single-instance=true";

      exec-once = [
        "dunst"
        "systemctl --user start hyprpolkitagent"
        "waybar"
        "hyprpaper"
      ];

      bind = [
        "$mod_SHIFT, Q, killactive"
        "$mod, space, exec, rofi -show drun"
        "$mod_SHIFT, S, exec, hyprshot -m region --clipboard-only"

        # Semantic Workspace Access
        "$mod,1,workspace,1" # Default 1
        "$mod,A,workspace,2" # A for AI
        "$mod,B,workspace,3" # B for Browser
        "$mod,E,workspace,4" # E for Email or Editor
        "$mod,T,workspace,5" # T for Terminal
        "$mod,S,workspace,6" # S for Slack or Social
        "$mod,M,workspace,7" # M for Music or Meetings
        "$mod,O,workspace,8" # O for Obsidian or Organisation
        "$mod,P,workspace,9" # P for Projects

        # Move Focused Window to Mapped Workspace
        "$mod_SHIFT,1,movetoworkspace,1"
        "$mod_SHIFT,A,movetoworkspace,2"
        "$mod_SHIFT,B,movetoworkspace,3"
        "$mod_SHIFT,E,movetoworkspace,4"
        "$mod_SHIFT,T,movetoworkspace,5"
        "$mod_SHIFT,S,movetoworkspace,6"
        "$mod_SHIFT,M,movetoworkspace,7"
        "$mod_SHIFT,O,movetoworkspace,8"
        "$mod_SHIFT,P,movetoworkspace,9"
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
        "DP-2,3840x2160@240,0x0,1, cm, hdr, sdrbrightness, 1.2, sdrsaturation, 0.98, vrr, 1"

      ];
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.96;
      };
      general = {
        border_size = 2;
        gaps_in = 5;
        gaps_out = 10;
        "col.active_border" = "0xffcba6f7";
        "col.inactive_border" = "0xff313244";
      };
    };
  };
}

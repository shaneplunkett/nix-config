{...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      exec-once = [
        "dunst"
        "systemctl --user start hyprpolkitagent"
        "waybar"
      ];

      bind = [
        "$mod_SHIFT, F, exec, zen"
        "$mod_SHIFT, Return, exec, ghostty"
        "$mod_SHIFT, Q, killactive"
        "$mod, space, exec, rofi -show drun"
        "$mod_SHIFT, S, exec, hyprshot -m region --clipboard-only"
      ];

      monitor = [
        # Center primary monitor
        "DP-2,3840x2160@122,0x0,1"

        # Left portrait monitor
        "HDMI-A-1,1920x2160@60,-1920x0,1"

        # Right portrait monitor
        "HDMI-A-2,1920x2160@60,3840x0,1"
      ];
      decoration = {
        rounding = 10;
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

{...}: {
  services.dunst = {
    enable = true;

    settings = {
      global = {
        monitor = "DP-2";
        origin = "top-center";
        offset = "0x20";
        font = "JetBrainsMono Nerd Font 10";
        frame_color = "#89b4fa";
        separator_height = 2;
        alignment = "center";
        corner_radius = 6;
        transparency = 10;
      };

      urgency_low = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 3;
      };

      urgency_normal = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 6;
      };

      urgency_critical = {
        background = "#f38ba8";
        foreground = "#1e1e2e";
        frame_color = "#f38ba8";
        timeout = 0;
      };
    };
  };
}

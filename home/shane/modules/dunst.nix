{...}: {
  services.dunst = {
    enable = true;

    settings = {
      global = {
        monitor = "DP-2";
        origin = "top-center";
        offset = "0x20";
        font = "JetBrainsMono Nerd Font 10";
        separator_height = 2;
        alignment = "center";
        corner_radius = 6;
        transparency = 10;
      };
    };
  };
}

{ ... }:
{
  services.dunst = {
    enable = false;

    settings = {
      global = {
        monitor = "DP-2";
        origin = "top-center";
        offset = "0x20";

        separator_height = 2;
        alignment = "center";
        corner_radius = 6;
        transparency = 10;
      };
    };
  };
}

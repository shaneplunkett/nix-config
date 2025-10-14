{ ... }:
{
  programs.rofi = {
    enable = true;
    theme = ./rofi-themes/rounded-nord-dark.rasi;
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
    };
  };
}

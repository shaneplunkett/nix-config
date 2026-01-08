{ ... }:
{
  programs.rofi = {
    enable = true;
    theme = ./rofi-themes/rounded-catppuccin-mocha.rasi;
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
    };
  };
}

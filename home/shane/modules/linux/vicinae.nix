# Raycast-style launcher; owns SUPER+space and SUPER+V in hyprland.nix.
# Catppuccin's autoEnable themes it to match everything else.
{ config, ... }:
let
  # Catppuccin's module asks for a "Catppuccin Mocha Mauve" icon theme under a
  # camelCase key vicinae doesn't read. Point it at the Catppuccin-tinted
  # Papirus set GTK already uses instead.
  iconTheme.icon_theme = "Papirus-Dark";
in
{
  programs.vicinae = {
    enable = true;
    systemd.enable = true;

    settings = {
      # Same font as the rest of the desktop (set in theme.nix). Size stays
      # unset so vicinae picks its own sensible default.
      font.normal.family = config.gtk.font.name;

      theme = {
        dark = iconTheme;
        light = iconTheme;
      };
    };
  };
}

{ pkgs, ... }:
let
  # Extra greeter entry: the same Hyprland, but NOCTALIA_GEN=5 makes the
  # hyprland.start hook (home/shane/modules/linux/noctalia.nix) launch the
  # sandboxed Noctalia v5 wrapper instead of the daily v4 shell.
  v5Session =
    (pkgs.writeTextDir "share/wayland-sessions/hyprland-noctalia-v5.desktop" ''
      [Desktop Entry]
      Name=Hyprland (Noctalia v5)
      Comment=Hyprland running the Noctalia v5 shell in its own config bubble
      Exec=env NOCTALIA_GEN=5 Hyprland
      Type=Application
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "hyprland-noctalia-v5" ];
      });
in
{
  services.displayManager.sessionPackages = [ v5Session ];
}

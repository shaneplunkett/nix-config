{ pkgs, compositor, ... }:
{
  programs = {
    neovim.defaultEditor = true;
    hyprland = {
      enable = compositor == "hyprland";
      xwayland.enable = true;
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
  };

  #Hyprland sessionVariables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    CLAUDE_USE_WAYLAND = "1";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    configPackages = [ pkgs.hyprland ];
  };
}

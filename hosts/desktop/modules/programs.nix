{ ... }:
{
  programs.neovim.defaultEditor = true;
  programs.hyprland = {
    enable = true;
  };

  #Hyprland sessionVariables
  environment.sessionVariables = {
    NIXOS_OZONE_LAYER = "1";
    MOZ_ENABLE_WAYLAND = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };

  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}

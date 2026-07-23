{ pkgs, ... }:
{
  programs = {
    neovim.defaultEditor = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
    # Run prebuilt dynamically-linked binaries (PyPI wheels like ruff,
    # pre-commit hook envs, vendor CLIs) without per-binary patchelf.
    nix-ld.enable = true;
  };

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

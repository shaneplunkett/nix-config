{ pkgs, ... }:
let
  claude-desktop = pkgs.callPackage ./claude-desktop/claude-desktop.nix { };
in
{
  capacities = pkgs.callPackage ./capacities/capacities.nix { };

  inherit claude-desktop;

  claude-desktop-with-fhs = pkgs.buildFHSEnv {
    name = "claude-desktop";
    targetPkgs = pkgs: with pkgs; [
      docker
      glibc
      openssl
      nodejs
      uv
      # GPU/rendering — electron needs these for hardware-accelerated compositing
      mesa
      libGL
      libdrm
      vulkan-loader
      # Wayland support
      wayland
    ];
    # --no-sandbox: electron's internal sandbox conflicts with bwrap's sandbox
    runScript = "${claude-desktop}/bin/claude-desktop";
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${claude-desktop}/share/applications/claude-desktop.desktop $out/share/applications/

      mkdir -p $out/share/icons
      cp -r ${claude-desktop}/share/icons/* $out/share/icons/
    '';
  };
}

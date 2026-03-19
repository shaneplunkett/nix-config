{ pkgs, compositor, ... }:
let
  sessionCmd = if compositor == "niri" then "niri-session" else "start-hyprland";
in
{

  services.xserver.videoDrivers = [ "amdgpu" ];
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.tailscale.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd ${sessionCmd} --greeting 'Welcome to NixOS!'";
        user = "greeter";
      };
    };
  };

  # Passwordless sudo for nixos-rebuild (allows Claude Code to switch)
  security.sudo.extraRules = [{
    users = [ "shane" ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];

  systemd.services.greetd = {
    serviceConfig = {
      Type = "idle";
    };
    unitConfig = {
      After = [ "multi-user.target" ];
    };
  };

}

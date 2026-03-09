{ pkgs, ... }:
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
        command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd start-hyprland --greeting 'Welcome to NixOS!'";
        user = "greeter";
      };
    };
  };

  systemd.services.greetd = {
    serviceConfig = {
      Type = "idle";
    };
    unitConfig = {
      After = [ "multi-user.target" ];
    };
  };

}

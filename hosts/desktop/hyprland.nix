{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

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

  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  environment.systemPackages = with pkgs; [
    hyprpolkitagent
    wl-clipboard
    tuigreet
    thunar-archive-plugin
    thunar-volman
  ];
}

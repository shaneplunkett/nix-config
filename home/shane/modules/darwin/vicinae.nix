# Raycast-style launcher, toggled with Option+Space (vicinae's macOS
# default). home-manager's programs.vicinae is Linux-only, so this installs
# the package and runs the server from launchd instead.
{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.vicinae ];

  # Catppuccin still fills programs.vicinae.settings with its theme on darwin;
  # vicinae reads ~/.config/vicinae on macOS regardless of XDG.
  xdg.configFile."vicinae/settings.json".source =
    (pkgs.formats.json { }).generate "vicinae-settings"
      config.programs.vicinae.settings;

  launchd.agents.vicinae = {
    enable = true;
    config = {
      Program = "${pkgs.vicinae}/Applications/Vicinae.app/Contents/MacOS/Vicinae";
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}

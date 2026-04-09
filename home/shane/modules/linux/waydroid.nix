{ ... }:
{
  # Set Waydroid display to match effective monitor resolution (3840x2160 @ 1.5x)
  home.activation.waydroidDisplay = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      if command -v waydroid &>/dev/null; then
        waydroid prop set persist.waydroid.width 3840
        waydroid prop set persist.waydroid.height 2160
      fi
    '';
  };

  systemd.user.services.waydroid-session = {
    Unit = {
      Description = "Waydroid user session";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "waydroid session start";
      ExecStop = "waydroid session stop";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}

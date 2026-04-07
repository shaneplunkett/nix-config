{ ... }:
{
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

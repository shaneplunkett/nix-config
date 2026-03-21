# Google Calendar sync via vdirsyncer (iCal feed) + khal
# Noctalia auto-discovers khal calendars for its calendar widget.
#
# Setup: encrypt your Google Calendar secret iCal URLs:
#   cd ~/nix-config/secrets
#   agenix -e google-calendar-personal.age
#   agenix -e google-calendar-work.age
# URL from: Google Calendar → Settings → <calendar> → Integrate → Secret address in iCal format
{ config, pkgs, ... }:
{
  # ── vdirsyncer — syncs remote calendars to local .ics files ──
  programs.vdirsyncer.enable = true;

  # ── khal — CLI calendar that noctalia reads from ──
  programs.khal = {
    enable = true;
    locale = {
      dateformat = "%d/%m/%Y";
      timeformat = "%H:%M";
      datetimeformat = "%d/%m/%Y %H:%M";
      longdatetimeformat = "%A %d %B %Y %H:%M";
      default_timezone = "Australia/Melbourne";
      unicode_symbols = true;
      firstweekday = 0; # Monday
    };
  };

  # ── Calendar accounts ──
  accounts.calendar = {
    basePath = ".local/share/calendars";

    accounts.personal = {
      primary = true;

      local = {
        type = "filesystem";
        fileExt = ".ics";
      };

      remote = {
        type = "http";
      };

      vdirsyncer = {
        enable = true;
        urlCommand = [ "sh" "-c" "cat $XDG_RUNTIME_DIR/agenix/google-calendar-personal" ];
      };

      khal = {
        enable = true;
        color = "light green";
      };
    };

    accounts.work = {
      local = {
        type = "filesystem";
        fileExt = ".ics";
      };

      remote = {
        type = "http";
      };

      vdirsyncer = {
        enable = true;
        urlCommand = [ "sh" "-c" "cat $XDG_RUNTIME_DIR/agenix/google-calendar-work" ];
      };

      khal = {
        enable = true;
        color = "light blue";
      };
    };
  };

  # ── Periodic sync — every 15 minutes ──
  systemd.user.services.vdirsyncer-sync = {
    Unit.Description = "Sync calendars with vdirsyncer";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
    };
  };

  systemd.user.timers.vdirsyncer-sync = {
    Unit.Description = "Periodic vdirsyncer calendar sync";
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "15min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}

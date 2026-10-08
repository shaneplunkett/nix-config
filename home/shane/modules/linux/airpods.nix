# The librepods daemon behind Noctalia's AirPods widget (noctalia.nix enables
# the plugin). The fork's own unit runs %h/.local/bin/librepods, so this
# restates it against the store path, hardening included.
{ lib, pkgs, ... }:
let
  # The daemon notifies through Omarchy's
  # `omarchy notification send --app-name A -g GLYPH TITLE BODY`, and drops
  # the toast when omarchy isn't on PATH. This hands it to notify-send.
  omarchyNotify = pkgs.writeShellApplication {
    name = "omarchy";
    runtimeInputs = [ pkgs.libnotify ];
    text = ''
      [[ "''${1-}" == notification && "''${2-}" == send ]] || exit 1
      shift 2
      app=AirPods
      while (($#)); do
        case "$1" in
          --app-name) app=$2; shift 2 ;;
          -g) shift 2 ;;
          *) break ;;
        esac
      done
      exec notify-send --app-name="$app" \
        --icon=${pkgs.librepods-noctalia}/share/icons/hicolor/scalable/apps/librepods.svg \
        "$@"
    '';
  };
in
{
  home.packages = [ pkgs.librepods-noctalia ];

  systemd.user.services.librepods = {
    Unit = {
      Description = "librepods AirPods daemon";
      # The AAP link needs BlueZ and a session bus, both of which arrive with
      # the graphical session.
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      # The BLE advertisement debug line fires several times a second.
      Environment = [
        "QT_LOGGING_RULES=openpods.debug=false"
        # Everything the daemon runs by name: notifications, bluetoothctl for
        # connect/disconnect, and `systemctl --user restart wireplumber`.
        "PATH=${
          lib.makeBinPath [
            omarchyNotify
            pkgs.bluez
            pkgs.systemd
          ]
        }"
      ];
      ExecStart = "${pkgs.librepods-noctalia}/bin/librepods --headless";
      Restart = "on-failure";
      RestartSec = 5;

      # The status file carries the AirPods identity, so nothing the daemon
      # creates is world-readable.
      UMask = "0077";
      StateDirectory = "librepods";
      StateDirectoryMode = "0700";
      ConfigurationDirectory = "AirPodsTrayApp";
      ConfigurationDirectoryMode = "0700";
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      # ProtectHome also hides /run/user, where the control socket lives.
      ReadWritePaths = [ "%t" ];
      PrivateTmp = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      RestrictSUIDSGID = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      SystemCallArchitectures = "native";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      # BlueZ takes AF_BLUETOOTH, the HCI address-type probe takes AF_NETLINK,
      # everything else is a local socket.
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_BLUETOOTH"
        "AF_NETLINK"
      ];
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}

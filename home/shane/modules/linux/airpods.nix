# The librepods daemon behind Noctalia's AirPods widget (noctalia.nix enables
# the plugin). The fork's own unit runs %h/.local/bin/librepods, so this
# restates it against the store path, hardening included.
{ pkgs, ... }:
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
      Environment = [ "QT_LOGGING_RULES=openpods.debug=false" ];
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

{ config, pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-authkey.path;
    extraUpFlags = [
      "--hostname=mcphub"
      "--accept-routes"
      "--accept-dns=false"
    ];
  };

  # Trust all traffic on the Tailscale interface
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Allow MCPHub (3000) + Funnel (443)
  networking.firewall.allowedTCPPorts = [ 443 3000 ];

  # Accept all Tailscale traffic — must run AFTER tailscaled inserts ts-input
  systemd.services.tailscale-accept = {
    description = "Accept all Tailscale interface traffic";
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iptables}/bin/iptables -I INPUT 1 -i tailscale0 -j ACCEPT";
      ExecStop = "${pkgs.iptables}/bin/iptables -D INPUT -i tailscale0 -j ACCEPT";
    };
  };

  # Funnel oneshot — expose MCPHub via Tailscale Funnel
  systemd.services.tailscale-funnel = {
    description = "Tailscale Funnel for MCPHub";
    after = [ "tailscaled.service" "mcphub.service" ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.services.tailscale.package}/bin/tailscale funnel --bg 3000";
    };
  };
}

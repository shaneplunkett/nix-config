{ config, ... }:
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

  # Allow Funnel traffic on WAN
  networking.firewall.allowedTCPPorts = [ 443 ];

  # Accept all Tailscale traffic before tailscaled's ts-input chain can drop it
  networking.firewall.extraCommands = ''
    iptables -I INPUT 1 -i tailscale0 -j ACCEPT
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D INPUT -i tailscale0 -j ACCEPT 2>/dev/null || true
  '';

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

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
    # Let NixOS firewall handle rules — tailscaled's ts-input chain
    # drops incoming Tailscale traffic despite trustedInterfaces
    extraDaemonFlags = [ "--netfilter-mode=off" ];
  };

  # Trust all traffic on the Tailscale interface
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Allow Funnel traffic on WAN
  networking.firewall.allowedTCPPorts = [ 443 ];

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

_: {
  networking.networkmanager.enable = true;

  # Work's bastion web proxy routes one domain to a local resolver via a
  # systemd-resolved drop-in it writes at install time; NetworkManager hands
  # DNS off to resolved automatically once this is on.
  services.resolved.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };
}

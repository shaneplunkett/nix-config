_: {
  networking = {
    networkmanager.enable = true;
    modemmanager.enable = false;

    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
}

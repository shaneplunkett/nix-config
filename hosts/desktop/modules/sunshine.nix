_: {
  services.sunshine = {
    enable = true;
    autoStart = true;

    # Hyprland's wlroots capture path works without the broad CAP_SYS_ADMIN
    # capability required by KMS capture.
    capSysAdmin = false;
    openFirewall = false;

    settings = {
      capture = "wlr";
      encoder = "vaapi";
      adapter_name = "/dev/dri/renderD128";

      # Sunshine reports the primary DP-2 display as output ID 0.
      output_name = 0;

      # Remote access goes through Tailscale rather than router port forwards.
      upnp = "disabled";
      origin_web_ui_allowed = "pc";
      lan_encryption_mode = 2;
      wan_encryption_mode = 2;
    };
  };

  # Moonlight's streaming ports are exposed only on the wired home LAN.
  # tailscale0 is already trusted by networking.nix for remote streaming.
  networking.firewall.interfaces.enp10s0 = {
    allowedTCPPorts = [
      47984
      47989
      48010
    ];
    allowedUDPPorts = [
      47998
      47999
      48000
      48002
      48010
    ];
  };

  # Sunshine uses uinput for remote keyboard, mouse, and controller events.
  users.users.shane.extraGroups = [ "uinput" ];
}

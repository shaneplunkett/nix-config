{ pkgs, ... }:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  # Disable USB autosuspend for Elgato Wave:3 (0fd9:0070) — prevents timeout errors
  # through the monitor hub chain
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0fd9", ATTR{idProduct}=="0070", ATTR{power/autosuspend}="-1", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0fd9", ATTR{idProduct}=="0094", ATTR{power/autosuspend}="-1", ATTR{power/control}="on"
  '';

  # Reset USB hub chain after boot to force clean re-enumeration
  # Fixes intermittent enumeration failures with devices behind monitor KVM
  systemd.services.usb-hub-reset = {
    description = "Reset USB hub chain for monitor KVM";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = pkgs.writeShellScript "usb-hub-reset" ''
        # Find the ASUS monitor USB hub and rebind it to force re-enumeration
        for dev in /sys/bus/usb/devices/*/idVendor; do
          dir=$(dirname "$dev")
          vendor=$(cat "$dev" 2>/dev/null)
          product=$(cat "$dir/idProduct" 2>/dev/null)
          # ASUS USB2.1 Hub (0b05:1bd6) — the monitor's USB controller
          if [ "$vendor" = "0b05" ] && [ "$product" = "1bd6" ]; then
            devname=$(basename "$dir")
            driver="/sys/bus/usb/drivers/usb"
            if [ -e "$driver/$devname" ]; then
              echo "Resetting ASUS monitor USB hub: $devname"
              echo "$devname" > "$driver/unbind" 2>/dev/null || true
              sleep 2
              echo "$devname" > "$driver/bind" 2>/dev/null || true
            fi
          fi
        done
      '';
    };
  };
}

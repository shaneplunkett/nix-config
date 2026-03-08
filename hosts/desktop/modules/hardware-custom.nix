{ ... }:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.graphics = {
    enable = true;
  };

  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;
}

{ ... }:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = [ "amdgpu" ];
}

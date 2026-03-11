{ pkgs, ... }:
{
  # WiVRn — wireless OpenXR streaming for Quest 3 (uses Monado under the hood)
  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    autoStart = true;
  };

  # Steam hardware udev rules (controllers, HMDs)
  hardware.steam-hardware.enable = true;

  # 32-bit graphics support (required for Steam/Proton VR games)
  hardware.graphics.enable32Bit = true;

  # Vulkan layers and OpenVR-to-OpenXR translation
  environment.systemPackages = with pkgs; [
    monado-vulkan-layers
    opencomposite
  ];
}

{ ... }:
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    # AirPlay Support
    raopOpenFirewall = true;
    extraConfig.pipewire = {
      "10-airplay" = {
        name = "libpipewire-module-raop-discover";

      };

    };
  };
}

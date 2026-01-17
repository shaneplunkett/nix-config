{ pkgs, ... }:
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "soft";
      value = "4096";
    }
    {
      domain = "*";
      item = "nofile";
      type = "hard";
      value = "8192";
    }
  ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  systemd.user.services.pipewire-pulse.wantedBy = [ "pipewire.service" ];
}

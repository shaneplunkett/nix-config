{ pkgs, ... }:
{
  # v4l2loopback — creates a virtual camera device that OBS can output to
  boot.extraModulePackages = with pkgs.config.boot.kernelPackages or pkgs.linuxPackages_latest; [
    pkgs.linuxPackages_latest.v4l2loopback
  ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1
  '';

  environment.systemPackages = [
    # OBS with background removal plugin
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        obs-backgroundremoval
      ];
    })

    # Camera controls GUI for tweaking webcam settings (exposure, white balance, etc.)
    pkgs.cameractrls-gtk4
  ];
}

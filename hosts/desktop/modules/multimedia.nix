{ config, pkgs, ... }:
{
  # v4l2loopback — creates a virtual camera device that OBS can output to
  boot.extraModulePackages = [
    config.boot.kernelPackages.v4l2loopback
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

  # Virtual audio loopback — creates a sink OBS outputs to and a source Chrome sees as a mic
  services.pipewire.extraConfig.pipewire."20-obs-virtual-mic" = {
    "context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "node.description" = "OBS Virtual Mic";
          "capture.props" = {
            "node.name" = "obs_virtual_mic_sink";
            "media.class" = "Audio/Sink";
            "audio.position" = [ "FL" "FR" ];
          };
          "playback.props" = {
            "node.name" = "obs_virtual_mic_source";
            "media.class" = "Audio/Source";
            "audio.position" = [ "FL" "FR" ];
          };
        };
      }
    ];
  };
}

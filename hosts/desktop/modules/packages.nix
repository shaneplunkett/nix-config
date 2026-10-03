{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    home-manager
    gh
    gcc
    zip
    unzip
    psmisc
    python3
    yq-go
    lsof
    wl-clipboard
    nemo-with-extensions
    file-roller
    openocd

    ffmpeg
    pulseaudio
  ];

}

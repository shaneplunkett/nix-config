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
    hyprpolkitagent
    wl-clipboard
    tuigreet
    nemo-with-extensions
    file-roller
    openocd

    # meeting transcription — meetscribe itself is added via home-manager
    # (home/shane/modules/common/meetscribe.nix) so it inherits an HF_TOKEN
    # wrapper sourced from agenix.
    ffmpeg
    pulseaudio # provides pactl for meetscribe audio device introspection
  ];

}

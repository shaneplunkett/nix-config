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
    # Work bastion scripts: a root daemon needs the stable root-owned
    # interpreter under /run/current-system, and mikefarah's yq (yq-go) —
    # the Python yq silently breaks their environment lookups. lsof is how
    # they detect the tunnel port, including from non-interactive shells.
    python3
    yq-go
    lsof
    hyprpolkitagent
    wl-clipboard
    tuigreet
    nemo-with-extensions
    file-roller
    openocd

    ffmpeg
    pulseaudio
  ];

}

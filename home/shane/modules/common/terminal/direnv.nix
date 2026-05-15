_:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # Cold-start rbw-agent fetches (and longer nix builds) can blow past the
    # default 5s warn timeout. 30s keeps direnv quiet through realistic loads.
    config.global.warn_timeout = "30s";
  };
}

{ ... }:
{
  programs.sesh = {
    enable = true;
    settings = { };

  };
  programs.fzf.tmux.enableShellIntegration = true;

}

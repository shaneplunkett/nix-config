{ ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      ls = "lsd";
    };
    interactiveShellInit = ''
      starship init fish | source

      if status is-interactive
          and not set -q TMUX
          exec tmux
      end
    '';
  };
}

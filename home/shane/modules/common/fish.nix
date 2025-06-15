{ ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      ls = "lsd";
    };
    generateCompletions = true;
    interactiveShellInit = ''
      starship init fish | source
      set -gx PATH $HOME/go/bin $PATH

    '';
  };
}

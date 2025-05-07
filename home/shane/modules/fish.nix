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
      direnv hook fish | source
    '';
  };
}

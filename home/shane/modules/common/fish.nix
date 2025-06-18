{ ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      ls = "lsd";
      drs = "sudo darwin-rebuild switch --flake ~/nix-config";
    };
    generateCompletions = true;
    interactiveShellInit = ''
      starship init fish | source
      set -gx PATH $HOME/go/bin $PATH

    '';
  };
}

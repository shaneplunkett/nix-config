{ ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      ls = "lsd";
      drs = "sudo darwin-rebuild switch --flake ~/nix-config";
      nrs = "sudo nixos-rebuild switch --flake ~/nix-config#desktop";
      ngc = "sudo nix-collect-garbage -d";
    };
    generateCompletions = true;
    interactiveShellInit = ''
      set fish_greeting
      starship init fish | source
      set -gx PATH $HOME/go/bin $PATH

    '';
  };
}

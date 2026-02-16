{ ... }:
{
  programs.sesh = {
    enable = true;
    settings = {
      nixconfig = {
        path = "~/nix-config/";
        startup_command = "nvim";
      };

    };

  };
  programs.fzf.tmux.enableShellIntegration = true;

}

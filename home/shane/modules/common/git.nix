{ ... }:
{
  programs.git = {
    enable = true;
    userName = "shaneplunkett";
    userEmail = "113661103+shaneplunkett@users.noreply.github.com";
    ignores = [
      ".direnv/"
      ".go/"
    ];
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
      push = {
        autoSetupRemote = true;
      };
      merge = {
        conflictstyle = "diff3";
      };
      core.sshCommand = "ssh -i ~/.ssh/id_ed25519";
    };
  };
}

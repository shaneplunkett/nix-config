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
    includes = [
      {
        condition = "gitdir:~/projects/work/";
        contents = {
          core.excludesfile = "~/.gitignore_work";
        };
      }
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
      core = {
        sshCommand = "ssh -i ~/.ssh/id_ed25519";
        editor = "nvim";
      };
    };
  };

  home.file.".gitignore_work".text = ''
    .envrc
    .direnv/
  '';
}

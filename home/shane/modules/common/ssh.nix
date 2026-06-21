_:
let
  shaneHost = {
    User = "shane";
    IdentityFile = [ "~/.ssh/id_ed25519" ];
  };
  laptopHost = shaneHost // {
    ServerAliveInterval = 60;
    ServerAliveCountMax = 3;
    RequestTTY = "yes";
    RemoteCommand = "fish -l";
  };
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        SetEnv = {
          TERM = "xterm-256color";
        };
      };

      "github.com" = {
        IdentityFile = [ "~/.ssh/id_ed25519" ];
        IdentitiesOnly = true;
      };

      "pve" = shaneHost // {
        HostName = "pve";
      };
      "cube" = shaneHost // {
        HostName = "cube";
      };
      "desktop" = shaneHost // {
        HostName = "desktop";
      };
      "mbp" = laptopHost // {
        HostName = "100.101.140.9";
        HostKeyAlias = "shanes-macbook-pro";
      };
      "wmbp" = laptopHost // {
        HostName = "shanes-work-macbook-pro";
      };
    };
  };
}

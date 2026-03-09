{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        setEnv = {
          TERM = "xterm-256color";
        };
      };

      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };

      "pve" = {
        hostname = "pve";
        user = "shane";
        identityFile = "~/.ssh/id_ed25519";
      };

      "cube" = {
        hostname = "cube";
        user = "shane";
        identityFile = "~/.ssh/id_ed25519";
      };

      "desktop" = {
        hostname = "desktop";
        user = "shane";
        identityFile = "~/.ssh/id_ed25519";
      };

      "mbp" = {
        hostname = "shanes-macbook-pro";
        user = "shane";
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        extraOptions = {
          RequestTTY = "yes";
          RemoteCommand = "fish -l";
        };
      };

      "wmbp" = {
        hostname = "shanes-work-macbook-pro";
        user = "shane";
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        extraOptions = {
          RequestTTY = "yes";
          RemoteCommand = "fish -l";
        };
      };
    };
  };
}

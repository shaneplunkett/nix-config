{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
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
        requestTTY = "yes";
        remoteCommand = "fish -l";
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };

      "wmbp" = {
        hostname = "shanes-work-macbook-pro";
        user = "shane";
        identityFile = "~/.ssh/id_ed25519";
        requestTTY = "yes";
        remoteCommand = "fish -l";
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
    };
  };
}

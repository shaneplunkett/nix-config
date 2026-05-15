_:
let
  shaneHost = {
    user = "shane";
    identityFile = "~/.ssh/id_ed25519";
  };
  laptopHost = shaneHost // {
    serverAliveInterval = 60;
    serverAliveCountMax = 3;
    extraOptions = {
      RequestTTY = "yes";
      RemoteCommand = "fish -l";
    };
  };
in
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

      "pve" = shaneHost // {
        hostname = "pve";
      };
      "cube" = shaneHost // {
        hostname = "cube";
      };
      "desktop" = shaneHost // {
        hostname = "desktop";
      };
      "mbp" = laptopHost // {
        hostname = "shanes-macbook-pro";
      };
      "wmbp" = laptopHost // {
        hostname = "shanes-work-macbook-pro";
      };
    };
  };
}

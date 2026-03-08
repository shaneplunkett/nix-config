{ ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";

    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };

      "pve" = {
        hostname = "192.168.1.169";
        user = "shane";
        identityFile = "~/.ssh/id_ed25519";
      };

      "cube" = {
        hostname = "192.168.1.238";
        user = "shane";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}

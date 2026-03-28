{ ... }:
{

  imports = [
    ./plugins.nix
    ./skills.nix
    ./theme.nix
    ./rules.nix
    ./mcp.nix
    ./permissions.nix
  ];

  programs.opencode = {
    enable = false;
    web.enable = false;
  };

  programs.opencode.settings.server = {
    hostname = "127.0.0.1";
    port = 4096;
  };

}

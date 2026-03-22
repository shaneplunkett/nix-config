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
    enable = true;
    web.enable = true;
  };

  programs.opencode.settings.server = {
    hostname = "127.0.0.1";
    port = 4096;
  };

}

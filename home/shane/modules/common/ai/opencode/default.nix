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
  };

}

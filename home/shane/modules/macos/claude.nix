{ pkgs, config, ... }:
let
  shared = import ../common/claude-mcp.nix {
    inherit pkgs;
    homeDirectory = config.home.homeDirectory;
  };
in
{
  home.packages = shared.packages;

  home.file."Library/Application Support/Claude/claude_desktop_config.json" = {
    text = builtins.toJSON shared.config;
  };
}

{ pkgs, lib, config, ... }:
let
  shared = import ../common/mcp-servers.nix {
    inherit pkgs config;
    homeDirectory = config.home.homeDirectory;
  };
in
{
  home.packages = shared.packages;

  home.file."Library/Application Support/Claude/claude_desktop_config.json" = {
    text = builtins.toJSON { mcpServers = shared.mcpServers; };
  };
}

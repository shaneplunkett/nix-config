# Shared Claude Desktop configuration
# Platform-specific wrappers (linux/claude-desktop.nix, macos/claude.nix) import this
{
  pkgs,
  config,
  ...
}:
let
  shared = import ../mcp {
    inherit pkgs config;
    homeDirectory = config.home.homeDirectory;
  };
in
{
  # Only obsidian runs locally in Desktop — everything else goes through MCPHub
  desktopMcpServers = {
    obsidian = shared.mcpServers.obsidian;
  };

  packages = shared.packages;
}

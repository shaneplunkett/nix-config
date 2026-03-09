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
  desktopMcpServers = {
    neovim = shared.mcpServers.neovim;
    obsidian = shared.mcpServers.obsidian;
  };

  packages = shared.packages;
}

# Shared Claude Desktop configuration
# Platform-specific wrappers (linux/claude-desktop.nix, macos/claude.nix) import this
{
  pkgs,
  ...
}:
let
  shared = import ../mcp { inherit pkgs; };
in
{
  desktopMcpServers = {
    neovim = shared.mcpServers.neovim;
  };

  packages = shared.packages;
}

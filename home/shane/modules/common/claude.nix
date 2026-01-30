{ pkgs, homeDirectory }:
let
  shared = import ./mcp-servers.nix {
    inherit pkgs homeDirectory;
  };

  mcpConfig = {
    mcpServers = shared.mcpServers;
  };
in
{
  inherit (shared) packages;
  config = mcpConfig;
}

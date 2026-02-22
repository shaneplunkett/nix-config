{ pkgs, homeDirectory, config }:
let
  shared = import ./mcp-servers.nix {
    inherit pkgs homeDirectory config;
  };

  mcpConfig = {
    mcpServers = shared.mcpServers;
  };
in
{
  inherit (shared) packages mkGoogleWorkspace;
  config = mcpConfig;
}

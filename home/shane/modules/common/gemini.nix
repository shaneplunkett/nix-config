{
  config,
  pkgs,
  ...
}:

let
  mcpServers = import ./mcp-servers.nix {
    inherit pkgs;
    homeDirectory = config.home.homeDirectory;
  };
in
{
  # Generate Gemini CLI settings.json with shared MCP configuration
  home.file.".gemini/settings.json".text = builtins.toJSON {
    mcpServers = mcpServers.mcpServers;
  };
}

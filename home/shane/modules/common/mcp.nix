{
  pkgs,
  inputs,
  config,
  ...
}:
let
  # Get MCP server packages from the flake
  mcp-pkgs = inputs.mcp-servers-nix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
  ];

  # Configure Claude Desktop to use MCP servers
  home.file.".config/claude/claude_desktop_config.json" = {
    text = builtins.toJSON {
      mcpServers = {
        filesystem = {
          command = "${mcp-pkgs.filesystem}/bin/mcp-server-filesystem";
          args = [
            "${config.home.homeDirectory}/projects"
            "${config.home.homeDirectory}/documents"
          ];
        };

      };
    };
  };
}

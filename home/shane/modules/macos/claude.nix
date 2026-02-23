{ pkgs, lib, config, ... }:
let
  shared = import ../common/claude.nix {
    inherit pkgs config;
    homeDirectory = config.home.homeDirectory;
  };

  # Tiered MCP configs for Claude Code
  # User-level: memory + dev tools (available globally across all projects)
  userMcpServers = shared.mcpServerTiers.user // shared.mcpServerTiers.dev;
  # Home project-level: obsidian, todoist, google-workspace, desktop-commander, posthog
  homeMcpJson = builtins.toJSON { mcpServers = shared.mcpServerTiers.home; };
in
{
  home.packages = shared.packages;

  # Claude Desktop keeps ALL MCPs (no sub-agent architecture there)
  home.file."Library/Application Support/Claude/claude_desktop_config.json" = {
    text = builtins.toJSON shared.config;
  };

  # Claude Code tiered MCP deployment:
  # ~/.claude.json — user-level: memory + dev tools (github, context7, shadcn, chrome-devtools)
  # ~/.mcp.json — home project: obsidian, todoist, google-workspace, desktop-commander, posthog
  home.activation.claudeCodeMcpServers = let
    userServersJson = builtins.toJSON userMcpServers;
  in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # User-level: memory + dev tools (available in every project)
    CLAUDE_JSON="$HOME/.claude.json"
    if [ -f "$CLAUDE_JSON" ]; then
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq --argjson servers '${userServersJson}' '.mcpServers = $servers' "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" \
        && $DRY_RUN_CMD mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
    else
      $DRY_RUN_CMD echo '${builtins.toJSON { mcpServers = userMcpServers; }}' > "$CLAUDE_JSON"
    fi

    # Home project-level: home tier MCPs
    $DRY_RUN_CMD echo '${homeMcpJson}' > "$HOME/.mcp.json"
  '';
}

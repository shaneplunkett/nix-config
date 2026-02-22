{ pkgs, lib, config, ... }:
let
  shared = import ../common/claude.nix {
    inherit pkgs config;
    homeDirectory = config.home.homeDirectory;
  };

  mcpServersJson = builtins.toJSON shared.config.mcpServers;
in
{
  home.packages = shared.packages;

  home.file."Library/Application Support/Claude/claude_desktop_config.json" = {
    text = builtins.toJSON shared.config;
  };

  # Merge mcpServers into ~/.claude.json (Claude Code CLI reads user-scope MCP servers from here)
  home.activation.claudeCodeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CLAUDE_JSON="$HOME/.claude.json"
    if [ -f "$CLAUDE_JSON" ]; then
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq --argjson servers '${mcpServersJson}' '.mcpServers = $servers' "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" \
        && $DRY_RUN_CMD mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
    else
      $DRY_RUN_CMD echo '${builtins.toJSON { mcpServers = shared.config.mcpServers; }}' > "$CLAUDE_JSON"
    fi
  '';
}

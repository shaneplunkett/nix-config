{
  pkgs,
  lib,
  config,
  ...
}:
let
  shared = import ../common/ai/cdesktop {
    inherit pkgs config;
  };

  desktopMcpServers = shared.desktopMcpServers;
in
{
  home.packages = shared.packages;

  # Written as a real file (not symlink) so Claude Desktop can write back to it
  home.activation.claudeDesktopConfig = let
    configJson = builtins.toJSON { mcpServers = desktopMcpServers; };
  in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    $DRY_RUN_CMD mkdir -p "$(dirname "$CONFIG")"
    if [ -f "$CONFIG" ] && [ ! -L "$CONFIG" ]; then
      # Existing writable file — merge mcpServers, preserve other settings
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq --argjson servers '${builtins.toJSON desktopMcpServers}' \
        '.mcpServers = $servers' "$CONFIG" > "$CONFIG.tmp" \
        && mv "$CONFIG.tmp" "$CONFIG"
    else
      # First run or was a symlink — write fresh
      rm -f "$CONFIG"
      echo '${configJson}' > "$CONFIG"
    fi
  '';
}

{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  shared = import ../common/claude.nix {
    inherit pkgs config;
    homeDirectory = config.home.homeDirectory;
  };

  # Claude Desktop uses port 8001 for google-workspace OAuth to avoid
  # conflicting with Claude Code's instance on port 8000
  desktopMcpServers = shared.config.mcpServers // {
    google-workspace = shared.mkGoogleWorkspace 8001;
  };

  mcpServersJson = builtins.toJSON desktopMcpServers;

  claude-desktop-wrapped = pkgs.writeShellScriptBin "claude-desktop" ''
    EMPTY_WORKSPACE="$HOME/.cache/claude-empty-workspace"
    WORKSPACE_LINK="$HOME/.config/claude/current-workspace"

    mkdir -p "$HOME/.config/claude"

    # Use current directory if in a project, otherwise empty
    if [ "$PWD" != "$HOME" ] && [ "$PWD" != "/" ]; then
      ln -sfn "$PWD" "$WORKSPACE_LINK"
      echo "✓ Workspace: $PWD"
    else
      rm -rf "$EMPTY_WORKSPACE"
      mkdir -p "$EMPTY_WORKSPACE"
      ln -sfn "$EMPTY_WORKSPACE" "$WORKSPACE_LINK"
      echo "✓ Using empty workspace"
    fi

    nohup ${
      inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
    }/bin/claude-desktop \
      --enable-features=UseOzonePlatform \
      --ozone-platform=wayland \
      "$@" > /dev/null 2>&1 &

    disown
    echo "Claude Desktop started (PID: $!)"
  '';
in
{
  home.packages = [ claude-desktop-wrapped ] ++ shared.packages;

  home.file.".config/Claude/claude_desktop_config.json" = {
    text = builtins.toJSON { mcpServers = desktopMcpServers; };
  };

  # Merge mcpServers into ~/.claude.json (Claude Code CLI reads user-scope MCP servers from here)
  # Uses shared.config.mcpServers (port 8000) not desktopMcpServers (port 8001)
  home.activation.claudeCodeMcpServers = let
    claudeCodeServersJson = builtins.toJSON shared.config.mcpServers;
  in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CLAUDE_JSON="$HOME/.claude.json"
    if [ -f "$CLAUDE_JSON" ]; then
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq --argjson servers '${claudeCodeServersJson}' '.mcpServers = $servers' "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" \
        && $DRY_RUN_CMD mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
    else
      $DRY_RUN_CMD echo '${builtins.toJSON { mcpServers = shared.config.mcpServers; }}' > "$CLAUDE_JSON"
    fi
  '';

  home.file.".local/share/applications/claude-desktop.desktop".text = ''
    [Desktop Entry]
    Name=Claude Desktop
    Exec=${claude-desktop-wrapped}/bin/claude-desktop
    Icon=claude
    Type=Application
    Categories=Development;Utility;
  '';
}


{
  pkgs,
  lib,
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

    nohup ${pkgs.claude-desktop}/bin/claude-desktop \
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

  home.file.".local/share/applications/claude-desktop.desktop".text = ''
    [Desktop Entry]
    Name=Claude Desktop
    Exec=${claude-desktop-wrapped}/bin/claude-desktop
    Icon=claude
    Type=Application
    Categories=Development;Utility;
  '';

  # Symlink skills from ~/ai-skills/ into Desktop's skills-plugin directory
  home.activation.claudeDesktopSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PLUGIN_BASE="$HOME/.config/Claude/local-agent-mode-sessions/skills-plugin"
    # Find the skills directory (navigate UUID paths)
    SKILLS_TARGET=$($DRY_RUN_CMD find "$PLUGIN_BASE" -name "skills" -type d 2>/dev/null | head -1)

    if [ -n "$SKILLS_TARGET" ]; then
      # Symlink personal skills
      for skill in "$HOME/ai-skills/personal"/*/; do
        [ -d "$skill" ] || continue
        name=$(basename "$skill")
        $DRY_RUN_CMD ln -sfn "$skill" "$SKILLS_TARGET/$name"
      done

      # Symlink work skills
      for skill in "$HOME/ai-skills/work"/*/; do
        [ -d "$skill" ] || continue
        name=$(basename "$skill")
        $DRY_RUN_CMD ln -sfn "$skill" "$SKILLS_TARGET/$name"
      done

      # Update manifest.json with skills from ai-skills repo
      MANIFEST="$(dirname "$SKILLS_TARGET")/manifest.json"
      if [ -f "$MANIFEST" ]; then
        # Build JSON entries for each skill from SKILL.md frontmatter
        for skill in "$HOME/ai-skills/personal"/*/ "$HOME/ai-skills/work"/*/; do
          [ -d "$skill" ] || continue
          name=$(basename "$skill")
          SKILL_FILE="$skill/SKILL.md"
          [ -f "$SKILL_FILE" ] || continue

          # Extract description from frontmatter
          desc=$(${pkgs.gnused}/bin/sed -n '/^---$/,/^---$/{ /^description:/{ s/^description: *//; p; q; } }' "$SKILL_FILE")
          [ -z "$desc" ] && desc="Skill: $name"

          # Add to manifest if not already present
          if ! ${pkgs.jq}/bin/jq -e ".skills[] | select(.name == \"$name\")" "$MANIFEST" > /dev/null 2>&1; then
            $DRY_RUN_CMD ${pkgs.jq}/bin/jq \
              --arg name "$name" \
              --arg desc "$desc" \
              --arg now "$(date -u +%Y-%m-%dT%H:%M:%S.000000Z)" \
              '.skills += [{"skillId": ("nix-" + $name), "name": $name, "description": $desc, "creatorType": "user", "updatedAt": $now, "enabled": true}]' \
              "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"
          fi
        done
      fi
    fi
  '';
}

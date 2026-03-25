{
  pkgs,
  lib,
  config,
  ...
}:
let
  # MCP server definitions (MCPHub local docker compose + direct local servers)
  shared = import ../mcp {
    inherit pkgs config;
    homeDirectory = config.home.homeDirectory;
  };

  allMcpServers = shared.mcpServers;

  # tweakcc — Claude Code TUI customisation
  tweakcc = pkgs.callPackage ./tweakcc.nix { };
  tweakccConfig = ./tweakcc-config.json;

  # vex-statusline — themed status line
  vex-statusline = pkgs.writeShellScriptBin "vex-statusline" ''
    exec ${pkgs.python3}/bin/python3 ${./vex-statusline.py}
  '';

  # Settings as a Nix store JSON file — deployed as a mutable copy by activation
  # so Claude Code can write runtime changes (thinking level, etc.)
  settingsJson = pkgs.writeText "claude-code-settings.json" (builtins.toJSON ({
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    theme = "dark-ansi";
    outputStyle = "vex";

    permissions.allow =
      # MCP — MCPHub smart routing (memory, todoist, context7, github, etc.)
      [
        "mcp__claude_ai_MCPHub__search_tools"
        "mcp__claude_ai_MCPHub__describe_tool"
        "mcp__claude_ai_MCPHub__call_tool"
      ]
      ++
        # Bash — git (read-only)
        [
          "Bash(git log:*)"
          "Bash(git status:*)"
          "Bash(git diff:*)"
          "Bash(git show:*)"
          "Bash(git branch:*)"
          "Bash(git remote:*)"
          "Bash(git fetch:*)"
          "Bash(git rev-parse:*)"
        ]
      ++
        # Bash — filesystem (read-only)
        [
          "Bash(ls:*)"
          "Bash(cat:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(readlink:*)"
          "Bash(echo:*)"
          "Bash(which:*)"
          "Bash(file:*)"
          "Bash(wc:*)"
        ]
      ++
        # Bash — nix (non-destructive)
        [
          "Bash(nix eval:*)"
          "Bash(nix build:*)"
          "Bash(nix-shell:*)"
          "Bash(nix flake:*)"
          "Bash(nixos-rebuild build:*)"
          "Bash(nh home:*)"
        ]
      ++
        # Bash — tools
        [
          "Bash(TZ='Australia/Melbourne' date:*)"
          "Bash(python3:*)"
          "Bash(node:*)"
          "Bash(npx:*)"
          "Bash(claude:*)"
          "Bash(curl:*)"
          "Bash(gh api:*)"
          "Bash(gh repo:*)"
          "Bash(gh release:*)"
        ]
      ++
        # Bash — Google Workspace (read-only)
        [
          "Bash(gws gmail +triage:*)"
          "Bash(gws gmail +read:*)"
          "Bash(gws gmail users messages list:*)"
          "Bash(gws gmail users messages get:*)"
          "Bash(gws gmail users threads get:*)"
          "Bash(gws gmail users labels list:*)"
          "Bash(gws calendar:*)"
          "Bash(gws drive files list:*)"
        ]
      ++
        # Web
        [
          "WebSearch"
          "WebFetch"
        ];

    disabledMcpjsonServers = [
      "posthog"
    ];

    statusLine = {
      type = "command";
      command = "${vex-statusline}/bin/vex-statusline";
    };

    hooks = {
      PreCompact = [
        {
          hooks = [
            {
              type = "command";
              command = "cat $HOME/ai-skills/vex/hooks/compaction.md";
            }
          ];
        }
      ];
      SessionEnd = [
        {
          hooks = [
            {
              type = "command";
              command = "cat $HOME/ai-skills/vex/hooks/session-end.md";
            }
          ];
        }
      ];
      SessionStart = [
        {
          hooks = [
            {
              type = "command";
              command = "cat $HOME/ai-skills/vex/hooks/session-start.md";
            }
          ];
        }
        {
          matcher = "compact";
          hooks = [
            {
              type = "command";
              command = "cat $HOME/ai-skills/vex/hooks/session-reload.md && echo \"Git branch: $(git branch --show-current 2>/dev/null || echo N/A)\" && echo 'Recent commits:' && git log --oneline -5 2>/dev/null || true && echo 'Modified files:' && git diff --name-only 2>/dev/null || true";
            }
          ];
        }
      ];
    };
  }));

  claude-code-vex = pkgs.claude-code.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ tweakcc ];
    postInstall = old.postInstall + ''
      export TWEAKCC_CONFIG_DIR=$(mktemp -d)
      cp ${tweakccConfig} $TWEAKCC_CONFIG_DIR/config.json
      chmod u+w $TWEAKCC_CONFIG_DIR/config.json

      CLI=$out/lib/node_modules/@anthropic-ai/claude-code/cli.js
      BEFORE=$(sha256sum "$CLI" | cut -d' ' -f1)

      TWEAKCC_CC_INSTALLATION_PATH="$CLI" tweakcc --apply

      AFTER=$(sha256sum "$CLI" | cut -d' ' -f1)
      if [ "$BEFORE" = "$AFTER" ]; then
        echo "ERROR: tweakcc --apply made no changes to cli.js — patches are stale"
        exit 1
      fi
    '';
  });

in
{
  programs.claude-code = {
    enable = true;
    package = claude-code-vex;
    # settings intentionally omitted — deployed as mutable copy below
  };

  # Deploy settings.json as a mutable copy (not a symlink) so CC can write
  # runtime changes like thinking level. Nix content resets on each rebuild.
  home.activation.claudeCodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD install -m 644 ${settingsJson} "$HOME/.claude/settings.json"
  '';

  home.file.".claude/CLAUDE.md".text = ''
    # Vex
    @vex/core.md
  '';

  # Deploy Vex persona core from ai-skills repo
  home.activation.vexPersona = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.claude/vex"
    $DRY_RUN_CMD install -m 600 "$HOME/ai-skills/vex/core.md" "$HOME/.claude/vex/core.md"
  '';

  # Deploy Vex output style, rules, and agents from ai-skills repo
  home.activation.vexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Output style
    $DRY_RUN_CMD mkdir -p "$HOME/.claude/output-styles"
    $DRY_RUN_CMD install -m 644 "$HOME/ai-skills/vex/output-style.md" "$HOME/.claude/output-styles/vex.md"

    # Rules (prefixed with vex- for namespacing)
    $DRY_RUN_CMD mkdir -p "$HOME/.claude/rules"
    for rule in "$HOME/ai-skills/vex/rules"/*.md; do
      [ -f "$rule" ] || continue
      name=$(basename "$rule")
      $DRY_RUN_CMD install -m 644 "$rule" "$HOME/.claude/rules/vex-$name"
    done

    # Agents
    $DRY_RUN_CMD mkdir -p "$HOME/.claude/agents"
    for agent in "$HOME/ai-skills/vex/agents"/*.md; do
      [ -f "$agent" ] || continue
      name=$(basename "$agent")
      $DRY_RUN_CMD install -m 644 "$agent" "$HOME/.claude/agents/$name"
    done
  '';

  # Deploy all MCPs to ~/.claude.json (user-level, available everywhere)
  home.activation.claudeCodeMcpServers =
    let
      allServersJson = builtins.toJSON allMcpServers;
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      CLAUDE_JSON="$HOME/.claude.json"
      if [ -f "$CLAUDE_JSON" ]; then
        $DRY_RUN_CMD ${pkgs.jq}/bin/jq --argjson servers '${allServersJson}' '.mcpServers = $servers' "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" \
          && $DRY_RUN_CMD mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
      else
        $DRY_RUN_CMD echo '${builtins.toJSON { mcpServers = allMcpServers; }}' > "$CLAUDE_JSON"
      fi

      # Clean up old home-project MCP config if it exists
      rm -f "$HOME/.mcp.json"
    '';

  # Symlink personal skills from ~/ai-skills/ into ~/.claude/skills/
  # Work skills are installed separately via ~/projects/work/ag-ai-skills/install.sh
  home.activation.claudeCodeSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SKILLS_DIR="$HOME/.claude/skills"
    $DRY_RUN_CMD mkdir -p "$SKILLS_DIR"

    # Clean existing personal skill symlinks (managed by this activation)
    $DRY_RUN_CMD find "$SKILLS_DIR" -maxdepth 1 -type l -delete 2>/dev/null || true

    # Symlink personal skills
    for skill in "$HOME/ai-skills/personal"/*/; do
      [ -d "$skill" ] || continue
      name=$(basename "$skill")
      $DRY_RUN_CMD ln -sfn "$skill" "$SKILLS_DIR/$name"
    done
  '';
}

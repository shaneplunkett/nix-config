{
  pkgs,
  lib,
  config,
  ...
}:
let
  claudeNodejs = pkgs.nodejs;

  # MCP server definitions (MCPHub local docker compose + direct local servers)
  shared = import ../mcp {
    inherit pkgs config;
    homeDirectory = config.home.homeDirectory;
  };

  allMcpServers = shared.mcpServers;

  # tweakcc — Claude Code TUI customisation
  tweakcc = pkgs.callPackage ./tweakcc.nix { };
  tweakccConfig = ./tweakcc-config.json;

  claude-code-vex = pkgs.claude-code.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ tweakcc ];
    postInstall = old.postInstall + ''
      export HOME=$(mktemp -d)
      mkdir -p $HOME/.tweakcc
      cp ${tweakccConfig} $HOME/.tweakcc/config.json
      chmod u+w $HOME/.tweakcc/config.json
      TWEAKCC_CC_INSTALLATION_PATH=$out/lib/node_modules/@anthropic-ai/claude-code/cli.js \
        tweakcc --apply
    '';
  });

in
{
  programs.claude-code = {
    enable = true;
    package = claude-code-vex;

    settings = {
      theme = "dark-ansi";

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
        command = "${claudeNodejs}/bin/npx ccstatusline@latest";
      };

      hooks = {
        PreCompact = [
          {
            hooks = [
              {
                type = "command";
                command = "cat ${config.age.secrets.vex-compaction.path}";
              }
            ];
          }
        ];
        SessionStart = [
          {
            hooks = [
              {
                type = "command";
                command = "cat ${config.age.secrets.vex-session-start.path}";
              }
            ];
          }
          {
            matcher = "compact";
            hooks = [
              {
                type = "command";
                command = "cat ${config.age.secrets.vex-session-reload.path} && echo \"Git branch: $(git branch --show-current 2>/dev/null || echo N/A)\" && echo 'Recent commits:' && git log --oneline -5 2>/dev/null || true && echo 'Modified files:' && git diff --name-only 2>/dev/null || true";
              }
            ];
          }
        ];
      };
    };
  };

  home.file.".claude/CLAUDE.md".text = ''
    # Vex
    @vex/core.md
    @vex/interaction.md
    @vex/protocols.md
  '';

  home.activation.vexPersona = lib.hm.dag.entryAfter [ "writeBoundary" "agenixInstall" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.claude/vex"
    $DRY_RUN_CMD install -m 600 ${config.age.secrets.vex-core.path} "$HOME/.claude/vex/core.md"
    $DRY_RUN_CMD install -m 600 ${config.age.secrets.vex-interaction.path} "$HOME/.claude/vex/interaction.md"
    $DRY_RUN_CMD install -m 600 ${config.age.secrets.vex-protocols.path} "$HOME/.claude/vex/protocols.md"
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

  # Symlink skills from ~/ai-skills/ into ~/.claude/skills/
  home.activation.claudeCodeSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SKILLS_DIR="$HOME/.claude/skills"
    $DRY_RUN_CMD mkdir -p "$SKILLS_DIR"

    # Clean existing skill symlinks (managed by this activation)
    $DRY_RUN_CMD find "$SKILLS_DIR" -maxdepth 1 -type l -delete 2>/dev/null || true

    # Symlink personal skills
    for skill in "$HOME/ai-skills/personal"/*/; do
      [ -d "$skill" ] || continue
      name=$(basename "$skill")
      $DRY_RUN_CMD ln -sfn "$skill" "$SKILLS_DIR/$name"
    done

    # Symlink work skills
    for skill in "$HOME/ai-skills/work"/*/; do
      [ -d "$skill" ] || continue
      name=$(basename "$skill")
      $DRY_RUN_CMD ln -sfn "$skill" "$SKILLS_DIR/$name"
    done
  '';
}

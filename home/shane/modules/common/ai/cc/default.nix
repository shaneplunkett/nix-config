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
        # MCP — Memory (all operations)
        [
          "mcp__memory__create_entities"
          "mcp__memory__create_relations"
          "mcp__memory__add_observations"
          "mcp__memory__delete_entities"
          "mcp__memory__delete_observations"
          "mcp__memory__delete_relations"
          "mcp__memory__read_graph"
          "mcp__memory__search_nodes"
          "mcp__memory__open_nodes"
        ]
        ++
          # MCP — Todoist (all operations)
          [
            "mcp__todoist__todoist_task_create"
            "mcp__todoist__todoist_task_get"
            "mcp__todoist__todoist_task_update"
            "mcp__todoist__todoist_task_delete"
            "mcp__todoist__todoist_task_complete"
            "mcp__todoist__todoist_task_reopen"
            "mcp__todoist__todoist_task_close"
            "mcp__todoist__todoist_task_move"
            "mcp__todoist__todoist_task_reorder"
            "mcp__todoist__todoist_task_quick_add"
            "mcp__todoist__todoist_task_convert_to_subtask"
            "mcp__todoist__todoist_task_hierarchy_get"
            "mcp__todoist__todoist_task_day_order_update"
            "mcp__todoist__todoist_tasks_bulk_create"
            "mcp__todoist__todoist_tasks_bulk_update"
            "mcp__todoist__todoist_tasks_bulk_delete"
            "mcp__todoist__todoist_tasks_bulk_complete"
            "mcp__todoist__todoist_tasks_reorder_bulk"
            "mcp__todoist__todoist_completed_tasks_get"
            "mcp__todoist__todoist_subtask_create"
            "mcp__todoist__todoist_subtasks_bulk_create"
            "mcp__todoist__todoist_subtask_promote"
            "mcp__todoist__todoist_project_get"
            "mcp__todoist__todoist_project_create"
            "mcp__todoist__todoist_project_update"
            "mcp__todoist__todoist_project_delete"
            "mcp__todoist__todoist_project_archive"
            "mcp__todoist__todoist_project_collaborators_get"
            "mcp__todoist__todoist_project_move_to_parent"
            "mcp__todoist__todoist_project_invite"
            "mcp__todoist__todoist_project_notes_get"
            "mcp__todoist__todoist_project_note_create"
            "mcp__todoist__todoist_project_note_update"
            "mcp__todoist__todoist_project_note_delete"
            "mcp__todoist__todoist_projects_reorder"
            "mcp__todoist__todoist_archived_projects_get"
            "mcp__todoist__todoist_section_get"
            "mcp__todoist__todoist_section_create"
            "mcp__todoist__todoist_section_update"
            "mcp__todoist__todoist_section_delete"
            "mcp__todoist__todoist_section_move"
            "mcp__todoist__todoist_section_archive"
            "mcp__todoist__todoist_section_unarchive"
            "mcp__todoist__todoist_sections_reorder"
            "mcp__todoist__todoist_comment_create"
            "mcp__todoist__todoist_comment_get"
            "mcp__todoist__todoist_comment_update"
            "mcp__todoist__todoist_comment_delete"
            "mcp__todoist__todoist_label_get"
            "mcp__todoist__todoist_label_create"
            "mcp__todoist__todoist_label_update"
            "mcp__todoist__todoist_label_delete"
            "mcp__todoist__todoist_label_stats"
            "mcp__todoist__todoist_shared_labels_get"
            "mcp__todoist__todoist_shared_label_rename"
            "mcp__todoist__todoist_shared_label_remove"
            "mcp__todoist__todoist_filter_get"
            "mcp__todoist__todoist_filter_create"
            "mcp__todoist__todoist_filter_update"
            "mcp__todoist__todoist_filter_delete"
            "mcp__todoist__todoist_reminder_get"
            "mcp__todoist__todoist_reminder_create"
            "mcp__todoist__todoist_reminder_update"
            "mcp__todoist__todoist_reminder_delete"
            "mcp__todoist__todoist_duplicates_find"
            "mcp__todoist__todoist_duplicates_merge"
            "mcp__todoist__todoist_activity_get"
            "mcp__todoist__todoist_activity_by_project"
            "mcp__todoist__todoist_activity_by_date_range"
            "mcp__todoist__todoist_collaborators_get"
            "mcp__todoist__todoist_invitations_get"
            "mcp__todoist__todoist_invitation_accept"
            "mcp__todoist__todoist_invitation_reject"
            "mcp__todoist__todoist_invitation_delete"
            "mcp__todoist__todoist_notifications_get"
            "mcp__todoist__todoist_notification_mark_read"
            "mcp__todoist__todoist_notifications_mark_all_read"
            "mcp__todoist__todoist_user_get"
            "mcp__todoist__todoist_productivity_stats_get"
            "mcp__todoist__todoist_user_settings_get"
            "mcp__todoist__todoist_workspaces_get"
            "mcp__todoist__todoist_backups_get"
            "mcp__todoist__todoist_backup_download"
            "mcp__todoist__todoist_test_connection"
            "mcp__todoist__todoist_test_all_features"
            "mcp__todoist__todoist_test_performance"
          ]
        ++
          # MCP — Context7 (documentation lookup)
          [
            "mcp__context7__resolve-library-id"
            "mcp__context7__query-docs"
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
            "WebFetch(domain:github.com)"
            "WebFetch(domain:raw.githubusercontent.com)"
            "WebFetch(domain:www.npmjs.com)"
          ];

      # Only memory enabled by default — toggle others per session as needed
      disabledMcpjsonServers = [
        "apple-mail"
        "apple-shortcuts"
        "applescript"
        "chrome-devtools"
        "context7"
        "github"
        "google-workspace"
        "mac-messages"
        "neovim"
        "obsidian"
        "posthog"
        "shadcn"
        "todoist"
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
                command = "echo 'SESSION BOOT: You are Vex. Execute your Session Start protocol immediately: (1) Run TZ=Australia/Melbourne date via Bash. (2) Open memory nodes: Shane, Vex Persona, Interaction Preferences via MCP. (3) Check today daily note at ~/Prime/Daily/. (4) Greet Shane warmly — steady presence, acknowledge time of day. Do all of this BEFORE waiting for user input.'";
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

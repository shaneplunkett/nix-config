{ pkgs, lib, config, ... }:
let
  claudeNodejs = pkgs.nodejs;

  # tweakcc — Claude Code TUI customisation
  tweakcc = pkgs.callPackage ./tweakcc.nix {};
  tweakccConfig = ./tweakcc-config.json;

  # Patched Claude Code with Vex theme applied via tweakcc
  claude-code-vex = pkgs.claude-code.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ tweakcc ];
    postInstall = old.postInstall + ''
      # Apply Vex theme via tweakcc
      export HOME=$(mktemp -d)
      mkdir -p $HOME/.tweakcc
      cp ${tweakccConfig} $HOME/.tweakcc/config.json
      TWEAKCC_CC_INSTALLATION_PATH=$out/lib/node_modules/@anthropic-ai/claude-code \
        tweakcc --apply
    '';
  });

  # Skill names to deploy to ~/.claude/skills/
  skillNames = [
    "memory-save"
    "todoist-ops"
    "obsidian-ops"
    "google-ops"
    "work-ops"
    "daily"
    "weekly"
    "work"
    "pd-update"
  ];

  # Generate home.file entries for all skill files
  skillFiles = builtins.listToAttrs (map (name: {
    name = ".claude/skills/${name}/SKILL.md";
    value = {
      source = ./skills/${name}/SKILL.md;
    };
  }) skillNames);
in
{
  programs.claude-code = {
    enable = true;
    package = claude-code-vex;

    settings = {
      theme = "dark-ansi";

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
                command = "echo 'COMPACTION INSTRUCTIONS: Preserve all architectural decisions, file paths modified, key constraints, current task state, and user preferences. Summarize code changes with before/after context. Keep exact error messages and their resolutions. Maintain the full list of files created or modified.'";
              }
            ];
          }
        ];
        SessionStart = [
          {
            matcher = "compact";
            hooks = [
              {
                type = "command";
                command = "echo '--- Post-compaction context reload ---' && echo \"Git branch: $(git branch --show-current 2>/dev/null || echo N/A)\" && echo 'Recent commits:' && git log --oneline -5 2>/dev/null || true && echo 'Modified files:' && git diff --name-only 2>/dev/null || true";
              }
            ];
          }
        ];
      };
    };
  };

  # Deploy skill files and CLAUDE.md via home.file (plain files — not sensitive)
  home.file = skillFiles // {
    ".claude/CLAUDE.md".text = ''
      # Vex
      @vex/core.md
      @vex/interaction.md
      @vex/protocols.md
    '';
  };

  # Deploy vex persona files via activation script
  # (persona files come from agenix secrets — must use activation, not home.file)
  home.activation.vexPersona = lib.hm.dag.entryAfter [ "writeBoundary" "agenixInstall" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.claude/vex"
    $DRY_RUN_CMD install -m 600 ${config.age.secrets.vex-core.path} "$HOME/.claude/vex/core.md"
    $DRY_RUN_CMD install -m 600 ${config.age.secrets.vex-interaction.path} "$HOME/.claude/vex/interaction.md"
    $DRY_RUN_CMD install -m 600 ${config.age.secrets.vex-protocols.path} "$HOME/.claude/vex/protocols.md"
  '';
}

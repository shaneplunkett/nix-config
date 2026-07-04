{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  priv = inputs.nix-config-private.values;
  aiSkills = inputs.ai-skills;
  workPrompt = "${aiSkills}/work-claude/Prompt.md";

  claudeSettings = {
    feedbackSurveyRate = 0;
    autoMemoryEnabled = false;
    env = {
      OTEL_RESOURCE_ATTRIBUTES = "autograb_user=${priv.autograbUser},team=${priv.autograbTeam}";
    };
  };

  settingsFile = pkgs.writeText "claude-code-settings.json" (
    builtins.toJSON (
      claudeSettings
      // {
        "$schema" = "https://json.schemastore.org/claude-code-settings.json";
      }
    )
  );

  mkClaudeProfile =
    name: configDir:
    pkgs.writeShellApplication {
      inherit name;
      text = ''
        mkdir -p "$HOME/${configDir}"
        export CLAUDE_CONFIG_DIR="$HOME/${configDir}"
        exec ${lib.getExe pkgs.claude-code} --dangerously-skip-permissions "$@"
      '';
    };

  cc = mkClaudeProfile "cc" ".claude";
  ccw = mkClaudeProfile "ccw" ".claude-work";

  legacyClaudeProfileRels = [
    "agents"
    "agents.backup"
    "output-styles"
    "rules"
    "skills"
    "themes"
    "vex"
  ];

  cleanRelShellWords = rels: lib.concatMapStringsSep " " lib.escapeShellArg rels;
in
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
    settings = claudeSettings;
    enableMcpIntegration = true;
    skills = { };
  };

  home = {
    packages = [
      cc
      ccw
    ];

    file = {
      ".claude/CLAUDE.md" = {
        source = workPrompt;
        force = true;
      };
      ".claude-work/CLAUDE.md" = {
        source = workPrompt;
        force = true;
      };
      ".claude-work/settings.json" = {
        source = settingsFile;
        force = true;
      };
    };

    activation.cleanLegacyClaudeProfiles = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      for dir in "$HOME/.claude" "$HOME/.claude-work"; do
        if [ ! -d "$dir" ]; then
          continue
        fi

        for rel in ${cleanRelShellWords legacyClaudeProfileRels}; do
          target="$dir/$rel"
          if [ -e "$target" ] || [ -L "$target" ]; then
            $DRY_RUN_CMD rm -rf "$target"
          fi
        done
      done
    '';
  };
}

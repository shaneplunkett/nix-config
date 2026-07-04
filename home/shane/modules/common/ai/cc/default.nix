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
  };
}

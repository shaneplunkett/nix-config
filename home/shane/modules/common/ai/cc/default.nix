{
  config,
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
        exec ${lib.getExe config.programs.claude-code.finalPackage} --dangerously-skip-permissions "$@"
      '';
    };

  claudePersonal = mkClaudeProfile "claude-personal" ".claude";
  claudeWork = mkClaudeProfile "claude-work" ".claude-work";
  claudePersonalExe = lib.getExe claudePersonal;
  claudeWorkExe = lib.getExe claudeWork;
in
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
    settings = claudeSettings;
    enableMcpIntegration = true;
    skills = { };
  };

  # Keep `cc` as an interactive convenience only. A real `cc` binary collides
  # with C compiler wrappers inside dev shells.
  programs.fish.shellAliases = {
    cc = claudePersonalExe;
    ccr = "${claudePersonalExe} --resume";
    ccw = claudeWorkExe;
    ccwr = "${claudeWorkExe} --resume";
  };

  home = {
    packages = [
      claudePersonal
      claudeWork
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
